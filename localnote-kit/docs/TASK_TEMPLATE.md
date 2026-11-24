# TASK TEMPLATE (copy to tasks/Txxx.md)

```
# Txxx: <title>

PHASE: <n>
DEPENDS ON: <task ids that must be DONE>
READ: ARCHITECTURE sections <..>; DESIGN_SPEC sections <..>; API_CHEATSHEET <letters>; TESTING section <..>

## GOAL
<2-3 sentences, observable outcome>

## FILES
Create:
- path
Modify:
- path (exact change)
Forbidden: everything else

## SPEC
<exact class names, signatures, constants, behavior rules; copy-pasteable code skeletons where it avoids ambiguity>

## STEPS
1. ...
2. ...

## TESTS (required)
- ClassName: `test name`  (what it asserts)

## VERIFY
bash tools/verify.sh  -> must print VERIFY: PASS

## HUMAN CHECK
- exact steps and expected result (reference TESTING.md Hnn)

## DO NOT
- task-specific traps
```

Writing rules for task authors:
- No "should consider", "appropriate", "etc.", "as needed". Every noun is a path, a name, or a number.
- If the task needs a decision, make it in DECISIONS.md, not in the task.
- If it needs more than ~300 lines of change, split it.
