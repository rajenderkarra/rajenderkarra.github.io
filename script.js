document.addEventListener("DOMContentLoaded", async () => {
  const pageDepth = window.location.pathname.split("/").filter(Boolean).length;
  const siteRoot = "../".repeat(pageDepth);
  const includePath = (name) => `${siteRoot}pages/${name}`;

  for (const element of document.querySelectorAll("[data-include]")) {
    const response = await fetch(includePath(element.dataset.include));
    if (response.ok) element.outerHTML = await response.text();
  }

  document.querySelectorAll("[data-root-link]").forEach((link) => {
    link.href = `${siteRoot}${link.dataset.rootLink}`;
  });

  const currentPath = window.location.pathname.replace(/\/$/, "");
  document.querySelectorAll(".nav-links a").forEach((link) => {
    if (link.pathname.replace(/\/$/, "") === currentPath) link.classList.add("active");
  });
});