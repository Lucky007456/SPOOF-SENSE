# Contributing to Spoof Sense

Thank you for your interest in contributing to **Spoof Sense**! This document provides guidelines and best practices for contributing.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Code Style Guidelines](#code-style-guidelines)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)

---

## 📜 Code of Conduct

This project adheres to the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code.

---

## 🛠️ How Can I Contribute?

### 🐛 Bug Reports
- Use the **Bug Report** issue template
- Include browser, OS, and steps to reproduce
- Attach screenshots or screen recordings if possible

### 💡 Feature Requests
- Use the **Feature Request** issue template
- Clearly describe the use case and expected behavior
- Discuss implementation approach if you have ideas

### 🔧 Code Contributions
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Implement your changes
4. Test thoroughly in both dark and light themes
5. Submit a Pull Request

### 📖 Documentation
- Fix typos, improve clarity, or add missing documentation
- Update hardware guides with new sensor configurations
- Add translation support

---

## 💻 Development Setup

```bash
# 1. Fork and clone
git clone https://github.com/YOUR_USERNAME/SPOOF-SENSE.git
cd SPOOF-SENSE

# 2. Open in browser (no build step required)
# The project uses vanilla HTML/CSS/JS with CDN dependencies

# 3. For live reload during development (optional)
npx live-server src/

# 4. Open src/index.html in your browser
# The app will enter Mock Mode automatically
```

### Prerequisites
- Modern browser (Chrome 90+, Firefox 88+, Edge 90+, Safari 14+)
- Git
- (Optional) Node.js for live-server

---

## 🎨 Code Style Guidelines

### HTML
- Use **semantic HTML5** elements
- Include descriptive `id` attributes on interactive elements
- Keep inline styles minimal — use CSS classes

### CSS
- Use **CSS custom properties** (variables) defined in `:root`
- Follow the existing naming convention: `--category-name`
- Support both `[data-theme="dark"]` and `[data-theme="light"]`
- Use `var(--transition)` for all theme-switchable properties

### JavaScript
- Use `const` and `let` (no `var`)
- Use arrow functions for callbacks
- Keep functions focused and under 30 lines
- Document complex logic with inline comments
- Use template literals for HTML construction

### SQL
- Use lowercase SQL keywords for consistency
- Include `IF NOT EXISTS` for all CREATE statements
- Always enable Row Level Security on new tables
- Add appropriate indexes for query performance

---

## 📝 Commit Message Convention

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <description>

[optional body]
[optional footer]
```

### Types
| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, no code change |
| `refactor` | Code restructuring |
| `perf` | Performance improvement |
| `test` | Adding tests |
| `chore` | Maintenance tasks |

### Examples
```
feat(map): add satellite orbit visualization layer
fix(ws): handle reconnection on network change
docs(readme): add Supabase setup screenshots
style(css): improve mobile responsive breakpoints
```

---

## 🔀 Pull Request Process

1. **Update documentation** if your change affects user-facing features
2. **Test in both themes** — ensure dark and light mode look correct
3. **Test mock mode** — ensure changes work without hardware
4. **Keep PRs focused** — one feature/fix per PR
5. **Reference issues** — link related issues in the PR description
6. **Request review** — tag a maintainer for review

### PR Title Format
```
[TYPE] Brief description of change
```

Example: `[FEAT] Add satellite constellation map panel`

---

## 🏗️ Areas for Contribution

Here are some areas where contributions are especially welcome:

- [ ] **Mobile responsive layout** — optimize panels for mobile screens
- [ ] **Notification sound** — audio alerts for threat detection
- [ ] **Historical playback** — replay past events from Supabase
- [ ] **Multi-device support** — monitor multiple ESP32 units
- [ ] **Geofencing** — alert when position leaves defined area
- [ ] **ML model integration** — TensorFlow.js for advanced detection
- [ ] **PWA support** — service worker for offline capabilities
- [ ] **Internationalization** — multi-language support

---

Thank you for contributing to GPS security research! 🛡️
