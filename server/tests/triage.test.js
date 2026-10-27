import test from 'node:test';
import assert from 'node:assert/strict';
import { score } from '../triage.js';

test('critical incidents score above low incidents', () => assert.ok(score('Critical', 'routine maintenance', false).score > score('Low', 'routine maintenance', false).score));
test('possible safety hazard adds an explainable signal', () => {
  const risky = score('High', 'open drain near school', false);
  const routine = score('High', 'routine road issue', false);
  assert.ok(risky.score > routine.score);
  assert.ok(risky.signals.includes('Potential safety/access risk detected'));
});
test('evidence increases score but caps at 99', () => assert.equal(score('Critical', 'open drain near school', true).score, 99));
test('rule output explicitly requires human review and disclaims trained AI', () => {
  const result = score('Medium', 'pothole', false);
  assert.ok(result.signals.includes('Human review is required'));
  assert.match(result.method, /not a trained AI model/);
});
