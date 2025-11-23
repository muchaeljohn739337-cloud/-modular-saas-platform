module.exports = {
  // Keep pre-commit fast and deterministic. Only lint Markdown with MD rules.
  "**/*.md": ["markdownlint-cli2"],
};
