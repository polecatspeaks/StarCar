// minidom.js - a DELIBERATELY minimal, hand-rolled DOM shim for the
// dom-writer.test.js smoke test (task 5.5: "render into a minimal DOM
// shim ... the modules are pure ESM"). Not a dependency, not a vendored
// library - just the handful of DOM methods dom-writer.js actually calls
// (createElement, appendChild, textContent, className, setAttribute),
// implemented as plain objects so the real dom-writer.js code can run
// unmodified against it with zero npm install and zero network access.
// This is TEST INFRASTRUCTURE ONLY - it never ships to the browser, which
// has its own real `document`.

class MiniElement {
  constructor(tagName) {
    this.tagName = tagName;
    this.children = [];
    this._textContent = '';
    this.className = '';
    this.attributes = {};
  }

  appendChild(child) {
    this.children.push(child);
    return child;
  }

  setAttribute(name, value) {
    this.attributes[name] = String(value);
  }

  get textContent() {
    // Mirrors real DOM semantics closely enough for this shim's purpose:
    // an element with children has no OWN text; a leaf's textContent is
    // whatever was last assigned.
    if (this.children.length > 0) {
      return this.children.map((c) => c.textContent).join('');
    }
    return this._textContent;
  }

  set textContent(value) {
    this._textContent = value;
    this.children = [];
  }

  querySelectorAll(selector) {
    // Only what dom-writer.test.js needs: a class-name selector (".foo").
    if (!selector.startsWith('.')) throw new Error(`minidom: unsupported selector ${selector}`);
    const cls = selector.slice(1);
    const out = [];
    const walk = (node) => {
      if (node.className && node.className.split(' ').includes(cls)) out.push(node);
      for (const c of node.children) walk(c);
    };
    walk(this);
    return out;
  }
}

export function createMiniDocument() {
  return {
    createElement(tagName) {
      return new MiniElement(tagName);
    }
  };
}
