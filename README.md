# Rajender Karra Personal Website

A professional static website for GitHub Pages, organized around focused content routes and reusable HTML fragments.

## Local preview

Run the included PowerShell web server:

```powershell
.\serve.ps1
```

If PowerShell blocks local scripts, run it once for this session with:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\serve.ps1
```

Or, if Python is installed, run:

```bash
python -m http.server 8000
```

Then visit:

```text
http://localhost:8000
```

## GitHub Pages

To publish on GitHub Pages, create a repository named `rajenderkarra.github.io` and push the contents here.

## Structure

- `about/` - professional background and engineering perspective
- `experience/` - career timeline and delivery experience
- `focus/` - AI engineering, system design, LLD, and product thinking
- `blog/ai/` - AI notes and project stories
- `blog/system-design/` - system design notes
- `blog/lld/` - low-level design notes
- `projects/` - enterprise and AI project portfolio
- `resume/` - online resume and PDF link
- `contact/` - email, LinkedIn, and GitHub links
- `pages/header.html` and `pages/footer.html` - shared fragments injected by `script.js`

The site uses client-side fragment loading so the shared navigation and footer are maintained in one place while remaining compatible with GitHub Pages.
