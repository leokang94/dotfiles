# 세팅 순서

## 1. Homebrew 설치
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## 2. Homebrew로 git 설치
```bash
brew install git
```
## 3. GCM (Git Credential Manager) 설치
```bash
brew install --cask git-credential-manager
```

## 4. Git Clone
```bash
git clone https://github.com/leokang94/dotfiles.git ~/.dotfiles
```

## 5. bootstrap.sh 실행
```bash
sh ~/.dotfiles/bootstrap.sh
```

## 6. 이후 추가 세팅 진행...
