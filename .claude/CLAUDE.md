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
- Use configured git aliases from dotfiles/.gitconfig when performing git operations
- Prefer `git sw` (switch) over `git co` (checkout) for branch switching
- Use `git pfl` (push --force-with-lease) instead of regular push for safer force pushes
- Available useful aliases:
  - `git s` for short status (`git status -s`)
  - `git sw` for switch operations
  - `git swd` for detached switch (`git switch --detach`)
  - `git pfl` for safe force push (`git push --force-with-lease`)
  - `git fp` for fetch with prune (`git fetch -p -P`)
  - `git cif` for amend commit (`git commit --amend --no-edit`)
  - `git rb` for rebase operations
- Always use these aliases when executing git commands to maintain consistency with user's workflow