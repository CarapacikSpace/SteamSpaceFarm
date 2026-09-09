using System.Collections.Concurrent;
using System.Text;
using System.Text.Json;

namespace SteamLibraryHelper;

internal interface IAuthInput
{
    Task<string?> ReadAsync(string kind, string prompt, bool secret, CancellationToken cancellationToken);
    void NotifyDeviceConfirmation();
}

internal sealed class ConsoleAuthInput : IAuthInput
{
    public Task<string?> ReadAsync(string kind, string prompt, bool secret, CancellationToken cancellationToken)
        => secret ? ConsoleInput.ReadSecretAsync(prompt, cancellationToken)
            : ConsoleInput.ReadLineAsync(prompt, cancellationToken);

    public void NotifyDeviceConfirmation()
        => Console.Error.WriteLine("[auth] confirm sign-in in Steam Mobile");
}

internal sealed class ProtocolAuthInput : IAuthInput, IDisposable
{
    private readonly Stream _input;
    private readonly CancellationTokenSource _operation;
    private readonly CancellationTokenSource _lifetime;
    private readonly Action<ProtocolEvent> _emit;
    private readonly ConcurrentDictionary<string, TaskCompletionSource<string?>> _pending = new();
    private readonly Task _reader;

    public ProtocolAuthInput(Stream input, CancellationTokenSource operation, Action<ProtocolEvent> emit)
    {
        _input = input;
        _operation = operation;
        _emit = emit;
        _lifetime = CancellationTokenSource.CreateLinkedTokenSource(operation.Token);
        _reader = Task.Run(ReadCommandsAsync);
    }

    public async Task<string?> ReadAsync(string kind, string prompt, bool secret, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        var id = Guid.NewGuid().ToString("N");
        var result = new TaskCompletionSource<string?>(TaskCreationOptions.RunContinuationsAsynchronously);
        _pending[id] = result;
        try
        {
            _emit(HelperJson.Input(id, kind, secret, prompt));
            return await result.Task.WaitAsync(cancellationToken).ConfigureAwait(false);
        }
        finally { _pending.TryRemove(id, out _); }
    }

    public void NotifyDeviceConfirmation() => _emit(HelperJson.Confirmation());

    private async Task ReadCommandsAsync()
    {
        try
        {
            var bytes = new byte[512];
            var frame = new List<byte>();
            var utf8 = new UTF8Encoding(false, true);
            while (true)
            {
                var count = await _input.ReadAsync(bytes, _lifetime.Token).ConfigureAwait(false);
                if (count == 0)
                {
                    _operation.Cancel();
                    return;
                }
                for (var index = 0; index < count; index++)
                {
                    if (bytes[index] == '\n')
                    {
                        Handle(utf8.GetString(frame.ToArray()));
                        frame.Clear();
                    }
                    else
                    {
                        if (frame.Count >= 16384) throw new FormatException();
                        frame.Add(bytes[index]);
                    }
                }
            }
        }
        catch (OperationCanceledException) when (_lifetime.IsCancellationRequested) { }
        catch (Exception)
        {
            if (!_lifetime.IsCancellationRequested)
            {
                _emit(HelperJson.InputFailed());
                _operation.Cancel();
            }
        }
    }

    private void Handle(string frame)
    {
        var command = JsonSerializer.Deserialize(frame, ProtocolJsonContext.Default.AuthCommand);
        if (command?.V != 1) throw new FormatException();
        switch (command.Command)
        {
            case "cancel":
                _operation.Cancel();
                break;
            case "auth.input":
                var id = command.RequestId;
                var value = command.Value;
                if (string.IsNullOrEmpty(id) || value is null) throw new FormatException();

                if (_pending.TryGetValue(id, out var pending)) pending.TrySetResult(value);
                break;
            default: throw new FormatException();
        }
    }

    public void Dispose()
    {
        _lifetime.Cancel();
        _ = _reader.ContinueWith(_ => _lifetime.Dispose(), TaskScheduler.Default);
    }
}
