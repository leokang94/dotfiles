# Claude Code Configuration for Senior Frontend Developer

## Language & Communication
- Always respond in Korean (한국어로 항상 응답)
- Provide clear and concise explanations
- Use technical terminology appropriately for senior-level understanding

## Task Planning & Execution
- Before making any file modifications, always create a detailed implementation plan
- Present the plan structure and sequence to the user for confirmation
- Wait for user approval before proceeding with actual changes
- Use TodoWrite tool to track multi-step tasks

## Development Environment
- Primary stack: TypeScript + React
- Focus on modern React patterns (hooks, functional components)
- Prioritize type safety and TypeScript best practices
- Consider performance implications and optimization opportunities

## Code Quality Standards
- Follow existing project conventions and patterns
- Maintain consistent code style and formatting
- Ensure proper TypeScript typing
- Implement error handling and edge cases
- Consider accessibility (a11y) requirements

## File Management
- Always prefer editing existing files over creating new ones
- Never create documentation files unless explicitly requested
- Maintain existing project structure and organization
- Check for existing implementations before adding new code

## Testing & Validation
- Run linting and type checking commands after code changes
- Verify functionality when possible
- Consider test coverage for new features
- Ensure changes don't break existing functionality

## Git Commands & Version Control
- **MANDATORY**: ALWAYS use `g` alias instead of `git` command for ALL git operations - NO EXCEPTIONS
- **MANDATORY**: Use `g pfl` (push --force-with-lease) instead of regular push for safer force pushes
- **NEVER** use raw `git` commands - ONLY use the configured aliases from dotfiles/.gitconfig
- **REQUIRED**: Use `g sw` (switch) instead of `g co` (checkout) for branch switching
- **Commit Message Review**: Always run `g s` to show staging status before confirming commit messages
- Available useful aliases:
  - `g s` for short status (`git status -s`)
  - `g a` for add (`git add`)
  - `g ci` for commit (`git commit`)
  - `g cie` for empty commit (`git commit --allow-empty`)
  - `g cif` for amend commit (`git commit --amend --no-edit`)
  - `g sw` for switch operations (`git switch`)
  - `g swd` for detached switch (`git switch --detach`)
  - `g co` for checkout (`git checkout`) - prefer `g sw` when possible
  - `g br` for branch (`git branch`)
  - `g rb` for rebase operations (`git rebase`)
  - `g pfl` for safe force push (`git push --force-with-lease`)
  - `g fp` for fetch with prune (`git fetch -p -P`)
  - `g cp` for cherry-pick (`git cherry-pick`)
  - `g db` for delete-branch
  - `g graph-log` for enhanced log with graph view
  - `g watch` for interactive log watching with hwatch
  - `g stl` for interactive stash list with fzf
  - `g ls` for interactive log selection with fzf
- **CRITICAL**: These aliases are MANDATORY for ALL git operations - violating this rule is unacceptable
