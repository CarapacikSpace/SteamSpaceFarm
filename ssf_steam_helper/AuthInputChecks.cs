using System.Text;
using System.Text.Json;
using System.Threading.Channels;

namespace SteamLibraryHelper;

internal static class AuthInputChecks
{
    public static async Task RunAsync()
    {
        using (var operation = new CancellationTokenSource())
        using (var stream = new TestInputStream())
        using (var input = new ProtocolAuthInput(stream, operation, message =>
        {
            if (message.Event != "auth.input") return;
            var request = message.Data;
            var requestId = request.GetProperty("requestId").GetString();
            stream.Send("{\"v\":1,\"command\":\"auth.input\",\"requestId\":\"stale\",\"value\":\"wrong\"}\n");
            stream.Send(JsonSerializer.Serialize(new AuthCommand(1, "auth.input", requestId, "synthetic-code"), ProtocolJsonContext.Default.AuthCommand) + "\n");
        }))
        {
            foreach (var kind in new[] { "username", "password", "email_code", "totp_code" })
            {
                var value = await input.ReadAsync(kind, "Synthetic prompt", true, operation.Token)
                    .WaitAsync(TimeSpan.FromSeconds(2));
                if (value != "synthetic-code") throw new InvalidOperationException("Auth request correlation failed.");
            }
        }

        foreach (var kind in new[] { "cancel", "eof", "oversized", "malformed" })
        {
            using var operation = new CancellationTokenSource();
            using var stream = new TestInputStream();
            using var input = new ProtocolAuthInput(stream, operation, _ => { });
            var pending = input.ReadAsync("totp_code", "Synthetic prompt", true, operation.Token);
            switch (kind)
            {
                case "cancel": stream.Send("{\"v\":1,\"command\":\"cancel\"}\n"); break;
                case "eof": stream.End(); break;
                case "oversized": stream.Send(new string('x', 16385)); break;
                case "malformed": stream.Send("[]\n"); break;
            }
            try
            {
                await pending.WaitAsync(TimeSpan.FromSeconds(2));
                throw new InvalidOperationException("Auth input should cancel: " + kind);
            }
            catch (OperationCanceledException) when (operation.IsCancellationRequested) { }
        }
    }

    private sealed class TestInputStream : Stream
    {
        private readonly Channel<byte[]> _queue = Channel.CreateUnbounded<byte[]>();
        private byte[] _current = [];
        private int _offset;
        public void Send(string value) => _queue.Writer.TryWrite(Encoding.UTF8.GetBytes(value));
        public void End() => _queue.Writer.TryComplete();
        public override async ValueTask<int> ReadAsync(Memory<byte> buffer, CancellationToken cancellationToken = default)
        {
            if (_offset == _current.Length)
            {
                if (!await _queue.Reader.WaitToReadAsync(cancellationToken)) return 0;
                _current = await _queue.Reader.ReadAsync(cancellationToken);
                _offset = 0;
            }
            var count = Math.Min(buffer.Length, _current.Length - _offset);
            _current.AsMemory(_offset, count).CopyTo(buffer);
            _offset += count;
            return count;
        }
        public override bool CanRead => true;
        public override bool CanSeek => false;
        public override bool CanWrite => false;
        public override long Length => throw new NotSupportedException();
        public override long Position { get => throw new NotSupportedException(); set => throw new NotSupportedException(); }
        public override void Flush() => throw new NotSupportedException();
        public override int Read(byte[] buffer, int offset, int count) => throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) => throw new NotSupportedException();
    }
}
