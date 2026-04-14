# EasyCrypt — GitHub Codespaces Environment

A ready-to-use development environment for EasyCrypt, designed for courses and workshops. Students open it in GitHub Codespaces and get a fully configured EasyCrypt installation in their browser — no local setup required.

## For students: getting started

1. Click the green **Code** button at the top of this repository.
2. Select the **Codespaces** tab.
3. Click **Create codespace on main**.
4. Wait ~30 seconds for the pre-built container image to be pulled (only on first launch; subsequent opens are instant).
5. Open any `.ec` file in `examples/` and start proving.

### Interactive proof navigation

The [EasyCrypt VS Code extension](https://marketplace.visualstudio.com/items?itemName=tornado.easycrypt-vscode) is pre-installed. It provides step-by-step proof navigation and a **Proof State** panel that shows the current goals — similar to ProofGeneral in Emacs.

Open `examples/hello_easycrypt.ec` and use these keybindings:

| Action | Linux / Windows | macOS |
|---|---|---|
| Step forward | `Ctrl+Alt+Down` | `Ctrl+Down` |
| Step backward | `Ctrl+Alt+Up` | `Ctrl+Up` |
| Go to cursor position | `Ctrl+Alt+Right` | `Ctrl+Right` |
| Reset proof state | `Ctrl+Alt+Left` | `Ctrl+Left` |
| Check whole file | `Ctrl+Shift+C` | `Cmd+Shift+C` |

The **Proof State** panel (Explorer sidebar) shows goals and messages as you step through the proof. If it is not visible, open it via **View → Open View → Proof State**.

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
