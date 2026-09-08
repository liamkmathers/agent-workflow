// Architecture as constraints. A PR that crosses one of these lines fails CI.
// Edit the paths to match your layout. Run locally: npx depcruise --config .dependency-cruiser.cjs __SRC_DIRS__
module.exports = {
  forbidden: [
    { name: 'no-circular', severity: 'error', from: {}, to: { circular: true } },
    { name: 'components-no-db', comment: 'UI never talks to the database directly',
      severity: 'error', from: { path: '^components' }, to: { path: '^lib/db' } },
    { name: 'routes-no-supabase-client', comment: 'routes go through lib/, not the raw client',
      severity: 'error', from: { path: '^app' }, to: { path: '^lib/supabase/client' } },
    { name: 'no-orphans', comment: 'framework entry files are imported by Next.js, not by code',
      severity: 'warn',
      from: { orphan: true,
        pathNot: '\\.d\\.ts$|\\.test\\.|\\.spec\\.|(^|/)(page|layout|loading|error|not-found|template|default)\\.tsx?$|(^|/)route\\.ts$|^middleware\\.ts$|^(next|postcss|tailwind|vitest|vite)\\.config' },
      to: {} },
  ],
  options: {
    tsConfig: { fileName: 'tsconfig.json' },
    exclude: { path: 'node_modules|\\.next|dist' },
  },
};
