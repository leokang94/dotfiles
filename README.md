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

### 7-0. MacOS 세팅
키보드 -> 키보드 단축키 -> 앱 단축키 -> `모든 응용프로그램` 내 아래 내용들 추가
- Minimize All : control+opts+shift+cmd+N
- 모두 최소화 : control+opts+shift+cmd+N
- Minimize : control+opts+shift+cmd+M 
- 최소화 : control+opts+shift+cmd+M

### 7-1. Karabiner 세팅
1. `Karabiner` > Simple Modifications > For all devices
  - caps_lock -> left_control
  - right_command -> f17 or f18
2. 시스템 설정 > 키보드 > 키보드 단축키 > 입력소스 > `입력 메뉴에서 다음 소스 선택` 을 f17 or f18 로 변경
  - 만약 이렇게 하고 안먹힐 경우 re-boot

### 7-2. App Store 를 통한 app 설치 및 활성화

- RunCat
- Xcode
- iShot
- Cursor Pro
- Kakaotalk
- CleanMyMac
- In Your Face

### 7-3. brew cask 를 통해 설치된 app 활성화

- Raycast
- 1Password
- Discord
- Aerospace
- Homerow
- Ghostty 

### 7-4 nvim 내에서 추가 설정

#### github-copilot 세팅
```
:Copilot auth
```

### 7-5 mouseless config 하드링크

```bash
rm -rf "$HOME/Library/Containers/net.sonuscape.mouseless/Data/.mouseless/configs/config.yaml" && \
ln ~/.dotfiles/.config/mouseless/config.yaml "$HOME/Library/Containers/net.sonuscape.mouseless/Data/.mouseless/configs/config.yaml"
```

> v0.5 에서 customizable config 지원 예정 ([문서](https://mouseless.click/docs/roadmap_and_issues.html#v05-upcoming))

## 8. 혹시 nvim 관련 충돌이 생긴다면?
```sh
rm -rf ~/.local/share/nvim && \
rm -rf ~/.local/state/nvim && \
rm -rf ~/.cache/nvim &&
```
을 통해 로컬 데이터들을 싹 정리하고 다시 설치하기
