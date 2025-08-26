## VSCode Client-side connection troubleshooting

Sometimes, when your container is about to start, the client-side connection can be:

```
{
    "objectscript.conn": {
        "server": "docker_pkg_manager",
        "ns": "USER",
        "active": false
    }
}
```

To reconnect the local src/ folder with the IRIS instance, just set "active" as true.

If VSCode returns an error, open the USER namespace in server-side mode, then just try to change again the "active" properties.
