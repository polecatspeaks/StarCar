// links.js (#28: clickable provenance). The ONE place a rendered fact turns
// into a real GitHub URL - built from GITHUB URLS constructed from
// repo-relative paths (the conductor's own ruling on this issue), never a
// localhost file route and never an absolute local path. Every function
// here returns null rather than a partial/guessed URL whenever an
// ingredient is missing - the wire's own honest-degrade contract
// (config.githubRepoUrl/githubArtifactsPrefix are "" when unconfigured):
// "no link, never a broken one".

/**
 * @param {{githubRepoUrl?: string, githubRef?: string, githubArtifactsPrefix?: string} | null | undefined} cfg
 * @param {string | undefined} recordDir - an entry's own wire recordDir
 *   (relative to the store root, e.g. "51-fix-review-r1").
 * @returns {string | null}
 */
export function buildRecordLink(cfg, recordDir) {
  if (!cfg || !cfg.githubRepoUrl || !cfg.githubArtifactsPrefix || !recordDir) return null;
  const ref = cfg.githubRef || 'dev';
  return `${cfg.githubRepoUrl}/tree/${ref}/${cfg.githubArtifactsPrefix}/${recordDir}`;
}

// Only the exact "#<digits>" shape is recognised - Law 1: a token that
// merely LOOKS like a ticket reference ("#28a", a bare "28") never becomes
// a guessed issue link.
const TICKET_TOKEN_PATTERN = /^#(\d+)$/;

/**
 * @param {{githubRepoUrl?: string} | null | undefined} cfg
 * @param {string | undefined} ticketToken - e.g. "#28"
 * @returns {string | null}
 */
export function buildIssueLink(cfg, ticketToken) {
  if (!cfg || !cfg.githubRepoUrl || typeof ticketToken !== 'string') return null;
  const m = TICKET_TOKEN_PATTERN.exec(ticketToken);
  if (!m) return null;
  return `${cfg.githubRepoUrl}/issues/${m[1]}`;
}
