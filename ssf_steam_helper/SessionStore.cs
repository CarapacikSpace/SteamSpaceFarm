using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace SteamLibraryHelper;

public interface ISessionStore
{
    SessionSecret? TryLoad();
    void Save(SessionSecret secret, CancellationToken cancellationToken);
    bool Forget(CancellationToken cancellationToken);
}

public sealed class DpapiSessionStore : ISessionStore
{
    private const int FormatVersion = 1;
    private const int MaxEnvelopeBytes = 64 * 1024;

    private static readonly byte[] Entropy = SHA256.HashData(
        Encoding.UTF8.GetBytes("SteamSpaceFarm.steam.session.v1"));

    private readonly string _path;

    public DpapiSessionStore(string path) => _path = path;

    public bool Exists => File.Exists(_path);

    public void Save(SessionSecret secret, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        if (!OperatingSystem.IsWindows())
            throw new PlatformNotSupportedException("The session store requires Windows DPAPI.");

        byte[] plain = JsonSerializer.SerializeToUtf8Bytes(secret, SessionJsonContext.Default.SessionSecret);
        byte[] protectedBytes = Array.Empty<byte>();
        try
        {
            protectedBytes = ProtectedData.Protect(
                plain,
                Entropy,
                DataProtectionScope.CurrentUser);
            var envelope = JsonSerializer.SerializeToUtf8Bytes(new SessionEnvelope(
                FormatVersion,
                Convert.ToBase64String(protectedBytes)), SessionJsonContext.Default.SessionEnvelope);

            var directory = Path.GetDirectoryName(_path);
            if (string.IsNullOrWhiteSpace(directory))
                throw new InvalidOperationException("Session path must have a directory.");

            Directory.CreateDirectory(directory);
            var tempPath = _path + "." + Guid.NewGuid().ToString("N") + ".tmp";
            try
            {
                cancellationToken.ThrowIfCancellationRequested();
                using (var stream = new FileStream(
                    tempPath,
                    FileMode.CreateNew,
                    FileAccess.Write,
                    FileShare.None,
                    bufferSize: 4096,
                    options: FileOptions.WriteThrough))
                {
                    stream.Write(envelope);
                    stream.Flush(flushToDisk: true);
                }

                cancellationToken.ThrowIfCancellationRequested();
                if (File.Exists(_path))
                    File.Replace(tempPath, _path, destinationBackupFileName: null);
                else
                    File.Move(tempPath, _path);
            }
            finally
            {
                if (File.Exists(tempPath))
                    File.Delete(tempPath);
            }
        }
        finally
        {
            CryptographicOperations.ZeroMemory(plain);
            if (protectedBytes.Length > 0)
                CryptographicOperations.ZeroMemory(protectedBytes);
        }
    }

    public SessionSecret? TryLoad()
    {
        if (!OperatingSystem.IsWindows() || !File.Exists(_path))
            return null;

        byte[]? envelopeBytes = null;
        byte[]? protectedBytes = null;
        byte[]? plain = null;
        try
        {
            using var stream = new FileStream(_path, FileMode.Open, FileAccess.Read, FileShare.Read);
            if (stream.Length <= 0 || stream.Length > MaxEnvelopeBytes)
                return null;

            envelopeBytes = new byte[(int)stream.Length];
            stream.ReadExactly(envelopeBytes);
            var envelope = JsonSerializer.Deserialize(envelopeBytes, SessionJsonContext.Default.SessionEnvelope);
            if (envelope is null
                || envelope.Version != FormatVersion
                || string.IsNullOrWhiteSpace(envelope.Ciphertext))
            {
                return null;
            }

            protectedBytes = Convert.FromBase64String(envelope.Ciphertext);
            if (protectedBytes.Length == 0)
                return null;

            plain = ProtectedData.Unprotect(
                protectedBytes,
                Entropy,
                DataProtectionScope.CurrentUser);
            var secret = JsonSerializer.Deserialize(plain, SessionJsonContext.Default.SessionSecret);
            return string.IsNullOrWhiteSpace(secret?.AccountName) || string.IsNullOrWhiteSpace(secret.RefreshToken)
                ? null : secret;
        }
        catch (CryptographicException)
        {
            return null;
        }
        catch (JsonException)
        {
            return null;
        }
        catch (FormatException)
        {
            return null;
        }
        catch (IOException)
        {
            return null;
        }
        catch (UnauthorizedAccessException)
        {
            return null;
        }
        finally
        {
            if (envelopeBytes is not null)
                CryptographicOperations.ZeroMemory(envelopeBytes);
            if (protectedBytes is not null)
                CryptographicOperations.ZeroMemory(protectedBytes);
            if (plain is not null)
                CryptographicOperations.ZeroMemory(plain);
        }
    }

    public bool Forget(CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        if (!File.Exists(_path))
            return false;
        File.Delete(_path);
        return true;
    }

}
