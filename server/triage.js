// Explainable triage rules. These are decision-support signals, not a trained AI model.
export function score(severity, description, hasPhoto) {
  const base = { Critical: 88, High: 72, Medium: 52, Low: 28 }[severity] ?? 45;
  const safety = /open manhole|open drain|accident|injur|electric|live wire|fire|collapse|danger|school|traffic|blocked emergency/i.test(description);
  const value = Math.min(99, base + (safety ? 8 : 0) + (hasPhoto ? 6 : 0));
  return { score: value, signals: [...(safety ? ['Potential safety/access risk detected'] : []), ...(hasPhoto ? ['Evidence image attached'] : []), `Reporter-selected severity: ${severity}`, 'Human review is required'], method: 'Transparent rule-based triage; not a trained AI model' };
}
