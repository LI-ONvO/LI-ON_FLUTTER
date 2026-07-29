---
description: 웹에서 확인한 표준 Git 커밋 컨벤션(Conventional Commits)에 맞춰 현재 변경사항의 커밋 메시지를 작성한다
---

`conventional-commit-writer` 서브에이전트를 호출해서 현재 변경사항에 대한 커밋 메시지를 작성한다.

절차:
1. Agent 도구로 `subagent_type: conventional-commit-writer`를 호출한다.
2. `$ARGUMENTS`가 있으면(예: 참고할 특정 컨벤션, 강조하고 싶은 변경 이유) 그 내용을 에이전트 프롬프트에 포함해서 전달한다. 없으면 저장소 경로와 "현재 변경사항에 대한 커밋 메시지를 작성해줘"만 전달한다.
3. 에이전트가 돌려준 커밋 메시지 초안과 참고한 컨벤션 출처를 사용자에게 그대로 보여준다.
4. 사용자가 명확히 커밋을 승인하기 전에는 `git add`/`git commit`을 실행하지 않는다.
