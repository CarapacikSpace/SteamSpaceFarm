using GetSteamApps.Models;
using SteamKit2;

namespace GetSteamApps.Core;

public static class SteamUtils
{
    public static KeyValueNode ConvertToKeyValueNode(KeyValue kv)
    {
        return new KeyValueNode
        {
            Name = kv.Name,
            Value = kv.Value,
            Children = kv.Children.Select(ConvertToKeyValueNode).ToList()
        };
    }
}