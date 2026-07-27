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

// #69/#71 (clickable provenance, board-conditions surface): a "discovery"
// condition (board/fold/algorithm.go's own "kind: X" / "outcome: X" detail
// shape, board/store/condition_severity.go's NOTE-tier example) names an
// undeclared VALUE, never a store subject - the honest link target is the
// vocab FILE that would declare it, not a record directory. schema/vocab/
// is this repo's OWN fixed layout (not the configured artifacts store
// prefix), so it is a repo-relative constant here, the same way the
// artifacts prefix is a repo-relative constant threaded through
// buildRecordLink - never a guessed value, never a hardcoded RECOGNITION
// VALUE (Law 7 binds the taxonomy of what counts as valid kind/outcome
// content, not this file's own directory layout).
export function buildVocabLink(cfg, filename) {
  if (!cfg || !cfg.githubRepoUrl || !filename) return null;
  const ref = cfg.githubRef || 'dev';
  return `${cfg.githubRepoUrl}/blob/${ref}/schema/vocab/${filename}`;
}

// #69/#71: the ONLY place a discovery condition's Detail text is inspected
// to choose a vocab file - board/fold/algorithm.go's Fold function's own
// discovery-collection loop builds Detail as EXACTLY "kind: " + value or
// "outcome: " + value (no other shape is ever emitted for the "discovery"
// code - cited by SYMBOL/shape, not line, per this repo's own convention),
// so this prefix check is pinned to a producer contract, never a loose
// guess. Any other shape (a future discovery kind this file does not yet
// know) resolves to null - no link, never a guessed one (Law 1).
export function vocabFilenameForDiscoveryDetail(detail) {
  if (typeof detail !== 'string') return null;
  if (detail.startsWith('kind: ')) return 'kinds.json';
  if (detail.startsWith('outcome: ')) return 'outcomes.json';
  return null;
}
