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

## 6. zsh --login (1passwor-cli를 통해 AI API key 들을 최초 1회 얻어오기 위함)
```bash
zsh --login
```

## 7. 이후 추가 세팅 진행

### 7-1. App Store 를 통한 app 설치 및 활성화

- RunCat
- Xcode
- iShot
- Cursor Pro
- Kakaotalk
- CleanMyMac
- In Your Face

### 7-2. brew cask 를 통해 설치된 app 활성화

- Raycast
- 1Password
- Discord
- Aerospace
- Homerow
- Ghostty 

### 7-3 nvim 내에서 추가 설정

#### github-copilot 세팅
```
:Copilot auth
```

### 7-4 mouseless config 하드링크

```bash
rm -rf "$HOME/Library/Containers/net.sonuscape.mouseless/Data/.mouseless/configs/config.yaml" && \
ln ~/.dotfiles/.config/mouseless/config.yaml "$HOME/Library/Containers/net.sonuscape.mouseless/Data/.mouseless/configs/config.yaml"
```

> v0.5 에서 customizable config 지원 예정 ([문서](https://mouseless.click/docs/roadmap_and_issues.html#v05-upcoming))
