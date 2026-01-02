# ApexGrid AI - CSV Results Import Template

## File Format

The CSV file must contain the following columns:

| Column | Required | Description | Valid Values |
|--------|----------|-------------|--------------|
| position | Yes | Finishing position | 1-20 (or blank for DNS) |
| driverGamertag | Yes | Driver's gamertag | Must match a driver in the league |
| teamShortName | Yes | Team short code | RBR, FER, MCL, MER, AMR, ALP, WIL, RB, SAU, HAA |
| sessionType | Yes | Type of session | QUALIFYING, SPRINT, RACE |
| status | Yes | Result status | FINISHED, DNF, DNS, DSQ |
| fastestLap | No | Did driver set fastest lap? | true, false (default: false) |
| gapToLeader | No | Time gap to leader | +X.XXX, DNF, DNS, DSQ (or blank) |

## Example

```csv
position,driverGamertag,teamShortName,sessionType,status,fastestLap,gapToLeader
1,Driver1_RBR,RBR,RACE,FINISHED,true,
2,Driver1_FER,FER,RACE,FINISHED,false,+5.123
3,Driver2_MCL,MCL,RACE,FINISHED,false,+8.456
...
19,Driver2_HAA,HAA,RACE,DNF,false,DNF
20,Reserve_RBR,RBR,RACE,DNS,false,DNS
```

## Session Types

- **QUALIFYING**: Qualifying session (Q1/Q2/Q3 combined results)
- **SPRINT**: Sprint race results (if weekend has sprint)
- **RACE**: Main race results

## Status Codes

- **FINISHED**: Driver completed the session
- **DNF**: Did Not Finish (retired from session)
- **DNS**: Did Not Start (absent or technical issue before start)
- **DSQ**: Disqualified (after post-session investigation)

## Points Calculation

Points are calculated automatically based on the league's scoring configuration:
- Race points are awarded for RACE sessions
- Sprint points are awarded for SPRINT sessions  
- Fastest lap bonus is awarded if `fastestLap=true` and driver finishes in top 10
- Pole position bonus is awarded for P1 in QUALIFYING

## Import Process

1. Go to **Admin Dashboard** → **Results** tab
2. Click **Import CSV**
3. Select the round you're importing results for
4. Upload your CSV file
5. Review the preview and confirm import

## Notes

- Drivers must exist in the league before importing results
- Team short names must match exactly (case-insensitive)
- Positions must be unique within each session type
- Re-importing will overwrite existing results for that round/session
