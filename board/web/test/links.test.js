// links.test.js (#28: clickable provenance). Pure string-building - the
// view's ONE place that turns config.githubRepoUrl/githubRef/
// githubArtifactsPrefix + an entry's own recordDir into a real URL, or null
// when the ingredients are incomplete (Law 1: no link, never a broken one).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildRecordLink, buildIssueLink, buildVocabLink, vocabFilenameForDiscoveryDetail } from '../js/links.js';

const fullCfg = {
  githubRepoUrl: 'https://github.com/polecatspeaks/StarCar',
  githubRef: 'dev',
  githubArtifactsPrefix: 'artifacts'
};

test('buildRecordLink: builds a full GitHub tree URL from repo + ref + prefix + recordDir', () => {
  assert.equal(
    buildRecordLink(fullCfg, '51-fix-review-r1'),
    'https://github.com/polecatspeaks/StarCar/tree/dev/artifacts/51-fix-review-r1'
  );
});

test('buildRecordLink: null when githubRepoUrl is unconfigured (non-GitHub yard)', () => {
  assert.equal(buildRecordLink({ ...fullCfg, githubRepoUrl: '' }, '51-fix-review-r1'), null);
});

test('buildRecordLink: null when githubArtifactsPrefix could not be resolved', () => {
  assert.equal(buildRecordLink({ ...fullCfg, githubArtifactsPrefix: '' }, '51-fix-review-r1'), null);
});

test('buildRecordLink: null when the entry itself carries no recordDir', () => {
  assert.equal(buildRecordLink(fullCfg, ''), null);
  assert.equal(buildRecordLink(fullCfg, undefined), null);
});

test('buildRecordLink: null when cfg itself is missing', () => {
  assert.equal(buildRecordLink(null, '51-fix-review-r1'), null);
  assert.equal(buildRecordLink(undefined, '51-fix-review-r1'), null);
});

test('buildIssueLink: a "#N" ticket token builds a GitHub issues URL', () => {
  assert.equal(buildIssueLink(fullCfg, '#28'), 'https://github.com/polecatspeaks/StarCar/issues/28');
});

test('buildIssueLink: null when githubRepoUrl is unconfigured', () => {
  assert.equal(buildIssueLink({ ...fullCfg, githubRepoUrl: '' }, '#28'), null);
});

test('buildIssueLink: null for a token that is not the exact "#digits" shape - never a guessed issue number', () => {
  assert.equal(buildIssueLink(fullCfg, '#28a'), null);
  assert.equal(buildIssueLink(fullCfg, '28'), null);
  assert.equal(buildIssueLink(fullCfg, ''), null);
  assert.equal(buildIssueLink(fullCfg, undefined), null);
});

// --- #69/#71: discovery conditions link to their vocab file, never a record ---

test('buildVocabLink: builds a full GitHub blob URL from repo + ref + schema/vocab/<filename>', () => {
  assert.equal(
    buildVocabLink(fullCfg, 'kinds.json'),
    'https://github.com/polecatspeaks/StarCar/blob/dev/schema/vocab/kinds.json'
  );
});

test('buildVocabLink: null when githubRepoUrl is unconfigured', () => {
  assert.equal(buildVocabLink({ ...fullCfg, githubRepoUrl: '' }, 'kinds.json'), null);
});

test('buildVocabLink: null when filename is missing', () => {
  assert.equal(buildVocabLink(fullCfg, ''), null);
  assert.equal(buildVocabLink(fullCfg, undefined), null);
});

test('buildVocabLink: null when cfg itself is missing', () => {
  assert.equal(buildVocabLink(null, 'kinds.json'), null);
  assert.equal(buildVocabLink(undefined, 'kinds.json'), null);
});

test('vocabFilenameForDiscoveryDetail: "kind: X" resolves to kinds.json', () => {
  assert.equal(vocabFilenameForDiscoveryDetail('kind: some-unrecognised-kind'), 'kinds.json');
});

test('vocabFilenameForDiscoveryDetail: "outcome: X" resolves to outcomes.json', () => {
  assert.equal(vocabFilenameForDiscoveryDetail('outcome: some-unrecognised-outcome'), 'outcomes.json');
});

test('vocabFilenameForDiscoveryDetail: an unrecognised shape resolves to null - never a guessed vocab file', () => {
  assert.equal(vocabFilenameForDiscoveryDetail('something else entirely'), null);
  assert.equal(vocabFilenameForDiscoveryDetail(''), null);
  assert.equal(vocabFilenameForDiscoveryDetail(undefined), null);
  assert.equal(vocabFilenameForDiscoveryDetail(null), null);
});
