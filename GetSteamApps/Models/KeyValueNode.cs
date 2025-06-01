using System.Text.Json.Serialization;

namespace GetSteamApps.Models;

public class KeyValueNode
{
    public string? Name { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Value { get; set; }

    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<KeyValueNode>? Children { get; set; }
}