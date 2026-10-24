import { readFileSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import { JSDOM } from "jsdom";

const roots = ["docs"];

function collect(dir, found = []) {
  for (const name of readdirSync(dir)) {
    const path = join(dir, name);
    if (statSync(path).isDirectory()) {
      collect(path, found);
    } else if (name.endsWith(".md")) {
      found.push(path);
    }
  }
  return found;
}

function diagrams(markdown) {
  const blocks = [];
  const pattern = /```mermaid\n([\s\S]*?)```/g;
  let match = pattern.exec(markdown);
  while (match) {
    blocks.push(match[1].trim());
    match = pattern.exec(markdown);
  }
  return blocks;
}

const dom = new JSDOM("<!DOCTYPE html><html><body></body></html>", {
  pretendToBeVisual: true,
});
const { window } = dom;
globalThis.window = window;
globalThis.document = window.document;
globalThis.DOMParser = window.DOMParser;
globalThis.HTMLElement = window.HTMLElement;
globalThis.SVGElement = window.SVGElement;
globalThis.Element = window.Element;
globalThis.Node = window.Node;
globalThis.getComputedStyle = window.getComputedStyle.bind(window);

const mermaid = (await import("mermaid")).default;
mermaid.initialize({ startOnLoad: false });

let count = 0;
const files = collect("docs");
for (const file of files) {
  const text = readFileSync(file, "utf8");
  const blocks = diagrams(text);
  for (const [index, block] of blocks.entries()) {
    try {
      await mermaid.parse(block);
      count += 1;
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      console.error(`${file} diagram ${index + 1} failed to parse:\n${message}`);
      process.exit(1);
    }
  }
}

if (count < 8) {
  console.error(`Expected at least 8 Mermaid diagrams, found ${count}`);
  process.exit(1);
}

console.log(`Parsed ${count} Mermaid diagrams in ${files.length} files.`);
