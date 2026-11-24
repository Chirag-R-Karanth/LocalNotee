# LocalNote

Offline-first Android notebook + PDF annotator. Kotlin, Jetpack Compose, no accounts, no cloud, no INTERNET permission.

## What this repo is

Code plus an **agent kit**: documents written so an AI coding agent never has to decide anything. The agent executes one small task at a time. A human reviews every task.

## The loop (this is the whole process)

```
Human: pick next task in PROGRESS.md
Human: open a FRESH agent session, paste docs/MASTER_PROMPT.md
Agent: reads rules -> reads ONE task file -> implements -> runs tools/verify.sh -> commits -> prints report -> STOPS
Human: reads report, runs verify.sh, runs the human checklist for that task
  pass -> mark task DONE in PROGRESS.md, go to next task
  fail -> git reset --hard HEAD~1, fix the TASK FILE (not the agent), retry in a fresh session
```

## Layout

```
README.md                 this file
PROGRESS.md               state tracker (agent updates, human approves)
docs/
  HOW_TO_BUILD.md         human setup + per-session steps
  MASTER_PROMPT.md        the prompt you paste every session
  AGENT_RULES.md          iron laws for the agent
  DECISIONS.md            every decision, already made
  ARCHITECTURE.md         packages, data model, formats, threading, algorithms
  DESIGN_SPEC.md          how the product looks and feels
  API_CHEATSHEET.md       known-good snippets for tricky Android APIs
  TESTING.md              test levels, evidence rules, human checklists
  DEPENDENCIES.md         allowed libraries and how versions are handled
  TROUBLESHOOTING.md      known errors and the only allowed fixes
  IMPLEMENTATION_PLAN.md  phases and task order
  TASK_TEMPLATE.md        format for new task files
tasks/T001.md ...         one file per task
tools/verify.sh           build + test + lint + no-internet check
tools/check_no_internet.sh
```

## Product in one paragraph

Import a PDF (it is copied into app storage) or create a blank notebook. Write with a stylus: pen, highlighter, eraser, undo/redo, palm rejection. Pages: add, duplicate, reorder, delete. Later: text boxes, images, shapes, scratch-to-erase, study tape. Autosave is journaled and survives process death. Export embeds annotations into a PDF (standard annotations plus a private data stream for lossless re-editing).

## Scope fence

In: ink, PDF pages, blank pages, text boxes, images, shapes, study tape, tags, search, quick checklist note.
Out: sync, accounts, collaboration, databases/blocks (Notion), web clipping, handwriting OCR, audio.
