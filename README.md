# EasyCrypt: Codespaces/Dev Container Environment

A ready-to-use development environment for EasyCrypt, designed for courses and workshops. Students can use it in two ways: in the browser via GitHub Codespaces, or locally in VS Code with Docker. No manual EasyCrypt installation required either way.

## For students: getting started

### Option A: GitHub Codespaces (browser, no local install)

1. Click the green **Code** button at the top of this repository.
2. Select the **Codespaces** tab.
3. Click **Create codespace on main**.
4. Wait until the pre-built container image to be pulled (only on first launch; subsequent opens should be quite fast).
5. Open any `.ec` file in `examples/` and start proving.

> 🚨 **Warning: delete your codespace when you are done.** 🚨 
>
> In the GitHub Codespaces free tier you have 120 hours/month compute allowance and 15GB/month storage allowance. Codespaces auto-suspend after 30 minutes of inactivity (pausing compute), but the stopped container keeps consuming your storage quota for up to 30 days before GitHub auto-deletes it. Each codespace takes about 3-4 GB of your 15 GB/month free allowance. Create a few and forget to delete them and you will exhaust your quota.
>
> To delete: go to [github.com/codespaces](https://github.com/codespaces), click `...` next to your codespace, and select **Delete**.

### Option B: Local VS Code with Docker (recommended if you have VS Code and Docker installed)

**Prerequisites:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) and the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) VS Code extension.

1. Clone this repository:
   ```bash
   git clone https://github.com/matteobusi/easycrypt-devcontainer.git
   cd easycrypt-devcontainer
   ```
2. Open the folder in VS Code:
   ```bash
   code .
   ```
3. VS Code will detect the `.devcontainer` configuration and show a prompt — click **Reopen in Container**.
   - If the prompt does not appear: open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run **Dev Containers: Reopen in Container**.
4. The pre-built image is pulled from GHCR. The EasyCrypt extension is installed automatically.
5. Open any `.ec` file in `examples/` and start proving.

### Interactive proof navigation

The [EasyCrypt VS Code extension](https://marketplace.visualstudio.com/items?itemName=tornado.easycrypt-vscode) is pre-installed. It provides step-by-step proof navigation and a **Proof State** panel that shows the current goals — similar to ProofGeneral in Emacs.

**Before stepping through a proof**, you must start the EasyCrypt process: open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and run **EasyCrypt: Start/Restart Process**. You need to do this once each time you open a new file.

Open `examples/hello_easycrypt.ec` and use these keybindings:

| Action | Keybinding |
|---|---|
| Step forward | `Alt+Down` |
| Step backward | `Alt+Up` |
| Go to cursor position | `Alt+Right` |
| Reset proof state | `Alt+Left` |
| Check whole file | `Ctrl+Shift+C` / `Cmd+Shift+C` |

The **Proof State** panel shows goals and messages as you step through the proof. By default it appears in the lower-left of the Explorer sidebar. If it is not visible, open it via **View → Open View → Proof State**. You can drag it to the right side of the editor if you prefer.

**Troubleshooting:**
- **No syntax highlighting?** Disable and re-enable the EasyCrypt extension: go to the Extensions sidebar, find "EasyCrypt", click the gear icon, and select **Disable**, then **Enable**. This is a known first-launch issue.
- **Proof State panel not visible?** Open it via **View → Open View → Proof State**, then drag it to your preferred position — VS Code will remember it.

### Checking from the terminal

You can also check a file in batch mode from the integrated terminal:

```bash
easycrypt examples/hello_easycrypt.ec
```

## For instructors: customising the environment

### Repository structure

```
.
├── .devcontainer/
│   ├── devcontainer.json   # Codespaces configuration
│   └── Dockerfile          # Container image definition
└── examples/
    └── hello_easycrypt.ec  # Starter file for students
```

### Adding course material

Drop `.ec` files into `examples/` (or any subdirectory). Students will see them in the file explorer when they open the Codespace.

### Changing the EasyCrypt version

The Dockerfile installs EasyCrypt from the current `main` branch via opam. To pin to a specific commit or tag, change the `opam pin` line in `.devcontainer/Dockerfile`:

```dockerfile
# Pin to a specific commit:
RUN opam pin -yn add easycrypt https://github.com/EasyCrypt/easycrypt.git#<commit-sha>
```

### Solvers installed

| Solver | Version | How installed |
|---|---|---|
| Z3 | 4.13.4 | upstream binary release (GitHub) |
| Alt-Ergo | 2.6.0 | `opam install alt-ergo.2.6.0` |

Both solvers are detected automatically by `easycrypt why3config`, which runs at image build time. No manual configuration is needed.

### Rebuilding the image

The container image is pre-built and hosted on GitHub Container Registry (GHCR). It is rebuilt automatically by the `devcontainer-build` GitHub Actions workflow whenever you push a change to `.devcontainer/Dockerfile` or `.devcontainer/devcontainer.json` on `main`.

To trigger a manual rebuild without a code change, go to **Actions → Build and publish devcontainer image → Run workflow**.

Once the new image is pushed, the next Codespace created by any student will use it automatically.

## Useful resources

- [EasyCrypt repository](https://github.com/EasyCrypt/easycrypt)
- [EasyCrypt reference manual](https://github.com/EasyCrypt/easycrypt/tree/main/docs)
- [EasyCrypt examples](https://github.com/EasyCrypt/easycrypt/tree/main/examples)
- [VS Code extension source](https://github.com/tornado80/easycrypt-vscode-ide)
- [Why3 documentation](https://www.why3.org/doc/)
- [GitHub Codespaces documentation](https://docs.github.com/en/codespaces)
