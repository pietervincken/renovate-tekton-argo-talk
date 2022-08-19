# Tekline

Filtering of tasks can be done through usage of the following labels and annotations.

| Name | Type | Default | Description |
|------|------|---------|-------------|
|`tekline.pietervincken.com/skip`|label|false|If true, skip during Tekline triggering (E.g. only manually trigger or through CronJob).|
|`tekline.pietervincken.com/run-regex`|annotation|""|Regex is matched against the revision name used by the pipeline. If the regex matches, the pipeline will be triggered|
|`tekline.pietervincken.com/skip-regex`|annotation|""|Regex is matched against the revision name used by the pipeline. If the regex matches, the pipeline will be skipped. If it doesn't match, it will be triggered|

## Truthtable
| run-regex  | skip-regex  | Pipeline triggered |
|---|---|---|
| Not present | Not present | Run  |
| Match | No Match | Run |
| Match | Not present | Run |
| Not present | No match  | Run |
| No match  | *  | Skip |
| *  | Match | Skip |

Next to the label based skipping, commit based skipping is also supported based on the `[skip ci]` match.
If `[skip ci]` is found in the commit message, no pipeline is triggered (not even the delegate).
