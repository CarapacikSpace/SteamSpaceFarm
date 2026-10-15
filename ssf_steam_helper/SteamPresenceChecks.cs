namespace SteamLibraryHelper;

internal static class SteamPresenceChecks
{
    internal static void Run()
    {
        foreach (var initial in new[] { 0, 1, 3, 7 })
        {
            var client = new FakePresence { State = initial };
            var lease = new InvisiblePresenceLease(client);
            if (client.State != 7) throw new InvalidOperationException("presence not invisible");
            lease.Dispose();
            lease.Dispose();
            if (client.State != initial || client.Changes != (initial == 7 ? 0 : 2))
                throw new InvalidOperationException("previous presence not restored exactly once");
        }
        var manual = new FakePresence { State = 1 };
        using (new InvisiblePresenceLease(manual)) { manual.State = 3; }
        if (manual.State != 3) throw new InvalidOperationException("manual status change overwritten");
        var switched = new FakePresence { State = 1 };
        using (new InvisiblePresenceLease(switched)) { switched.IsSameAccount = false; }
        if (switched.State != 7) throw new InvalidOperationException("changed another account's status");
        var failing = new FakePresence { State = 1, FailOnce = true };
        try { using var lease = new InvisiblePresenceLease(failing); throw new InvalidOperationException("failure ignored"); }
        catch (IOException) { }
        if (failing.State != 1) throw new InvalidOperationException("failed startup did not restore presence");
        foreach (var failure in new[] { "read", "write", "confirmed" })
        {
            var transient = new RetryPresence();
            var lease = new InvisiblePresenceLease(transient);
            transient.ReadFailures = failure == "read" ? 1 : 0;
            transient.WriteFailures = failure == "write" ? 1 : 0;
            transient.FailAfterWrite = failure == "confirmed";
            lease.Dispose();
            lease.Dispose();
            if (transient.Current != 1 || transient.Restores != 1)
                throw new InvalidOperationException($"transient {failure} did not restore exactly once");
        }
        foreach (var switchAccount in new[] { false, true })
        {
            var changed = new RetryPresence();
            var lease = new InvisiblePresenceLease(changed);
            changed.ReadFailures = 1;
            changed.OnReadFailure = () => { if (switchAccount) changed.IsSameAccount = false; else changed.Current = 3; };
            lease.Dispose();
            if (changed.Restores != 0 || changed.Current != (switchAccount ? 7 : 3))
                throw new InvalidOperationException("retry overwrote user status or another account");
        }
        var persistent = new RetryPresence();
        var retryable = new InvisiblePresenceLease(persistent);
        persistent.ReadFailures = 3;
        try { retryable.Dispose(); throw new InvalidOperationException("persistent failure ignored"); }
        catch (IOException) { }
        if (persistent.Current != 7) throw new InvalidOperationException("unexpected state after failure");
        retryable.Dispose();
        if (persistent.Current != 1 || persistent.Restores != 1)
            throw new InvalidOperationException("failed lease was prematurely disposed");
        var preferences = new SteamKit2.KeyValue("root");
        preferences.Children.Add(new SteamKit2.KeyValue("FriendStoreLocalPrefs_42", "{\"ePersonaState\":7}"));
        preferences.Children.Add(new SteamKit2.KeyValue("FriendStoreLocalPrefs_43", "{\"ePersonaState\":1}"));
        if (SteamPresencePreferences.Read(preferences, 42) != 7 || SteamPresencePreferences.Read(preferences, 99) != null)
            throw new InvalidOperationException("presence preferences account isolation failed");
        foreach (var invalid in new[] { "[]", "null", "{}", "{\"ePersonaState\":\"7\"}", "{\"ePersonaState\":99}", "broken" })
        {
            preferences.Children[0].Value = invalid;
            if (SteamPresencePreferences.Read(preferences, 42) != null)
                throw new InvalidOperationException("invalid presence preference accepted");
        }
    }

    private sealed class RetryPresence : IDesktopPresence
    {
        public int Current = 1;
        public int ReadFailures, WriteFailures, Restores;
        public bool FailAfterWrite;
        public Action? OnReadFailure;
        public bool IsSameAccount { get; set; } = true;
        public int State
        {
            get
            {
                if (ReadFailures > 0)
                {
                    ReadFailures--;
                    OnReadFailure?.Invoke();
                    throw new IOException("temporary read failure");
                }
                return Current;
            }
        }
        public void SetState(int state)
        {
            if (WriteFailures > 0) { WriteFailures--; throw new IOException("temporary write failure"); }
            Current = state;
            if (state == 1) Restores++;
            if (FailAfterWrite) { FailAfterWrite = false; throw new IOException("confirmation delayed"); }
        }
    }

    private sealed class FakePresence : IDesktopPresence
    {
        public int State { get; set; }
        public bool IsSameAccount { get; set; } = true;
        public bool FailOnce { get; set; }
        public int Changes { get; private set; }
        public void SetState(int state)
        {
            State = state;
            Changes++;
            if (FailOnce) { FailOnce = false; throw new IOException("simulated failure"); }
        }
    }
}
