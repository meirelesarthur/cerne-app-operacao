import { defineConfig, searchForWorkspaceRoot } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'node:path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    // respeita a porta atribuída pelo harness de preview (PORT); fallback 5173
    port: Number(process.env.PORT) || 5173,
    fs: {
      // git worktrees aninhadas resolvem @fontsource no node_modules do repo raiz
      allow: [searchForWorkspaceRoot(process.cwd()), path.resolve(__dirname, '../../..')],
    },
  },
})
