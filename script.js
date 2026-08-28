// Resolve resources from this script's location. This also supports a local
// preview where the repository is served from a subfolder.
const siteRoot = new URL(".", document.currentScript.src).href;

document.addEventListener("DOMContentLoaded", async () => {
  const includePath = (name) => new URL(`pages/${name}`, siteRoot).href;

  for (const element of document.querySelectorAll("[data-include]")) {
    const response = await fetch(includePath(element.dataset.include));
    if (response.ok) element.outerHTML = await response.text();
  }

  // Keep resolving placeholders until none remain, so a page can compose
  // other reusable page sections (for example, blog/index.html).
  while (true) {
    const element = document.querySelector("[data-page-include]");
    if (!element) break;
    const pagePath = new URL(element.dataset.pageInclude, siteRoot).href;
    const response = await fetch(pagePath);
    if (!response.ok) {
      element.remove();
      continue;
    }

    const page = new DOMParser().parseFromString(await response.text(), "text/html");
    const content = page.querySelector("main");
    if (!content) {
      element.remove();
      continue;
    }

    // Content is inserted into the home page, so make each relative link resolve
    // from the folder of the page it came from, rather than from the site root.
    content.querySelectorAll("a[href]").forEach((link) => {
      const href = link.getAttribute("href");
      if (href && !href.startsWith("#") && !/^[a-z][a-z0-9+.-]*:/i.test(href)) {
        link.href = new URL(href, new URL(pagePath, window.location.href)).href;
      }
    });

    element.replaceWith(...content.children);
  }

  document.querySelectorAll("[data-root-link]").forEach((link) => {
    link.href = new URL(link.dataset.rootLink, siteRoot).href;
  });

  const currentPath = window.location.pathname.replace(/\/$/, "");
  document.querySelectorAll(".nav-links a").forEach((link) => {
    if (link.pathname.replace(/\/$/, "") === currentPath) link.classList.add("active");
  });
});
