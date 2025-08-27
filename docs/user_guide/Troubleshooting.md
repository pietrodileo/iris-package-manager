# VSCode Client-side Connection Troubleshooting

When connecting your VSCode workspace to an InterSystems IRIS instance, you might find that the local connection is inactive. This is indicated by the `active` property being set to `false` in your `.vscode/settings.json` file, similar to the following:

```
{
    "objectscript.conn": {
        "server": "docker_pkg_manager",
        "ns": "USER",
        "active": false
    }
}

```

To re-establish the link between your local `src/` folder and the IRIS instance, you can simply change the `"active"` property to `true`.

If VSCode returns an error, it is recommended to open the `USER` namespace in server-side mode first. After the server-side connection is established, you can then try changing the `"active"` property back to `true` on the client side.
