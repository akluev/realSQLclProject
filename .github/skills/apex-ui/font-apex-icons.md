# Font APEX Icons — Complete Reference

**Source:** Oracle Database `WWV_FLOW_STANDARD_ICONS` table  
**Icon Library:** Font APEX (APEX 26.1)  
**Total Icons:** 1,539  
**Last Updated:** June 2, 2026

> **Version note:** This file is extracted from `APEX_260100.WWV_FLOW_STANDARD_ICONS`. The same query works for any APEX version — just replace the schema name. Use `select schema from dba_registry where comp_id = 'APEX'` to discover it dynamically.

## Overview

This file contains all available Font APEX icons extracted from the Oracle APEX metadata table. This is the **authoritative source** for icon names, ensuring accuracy (avoiding hallucinated icon names like `fa-chart-line` which should be `fa-line-chart`).

**Why this is the authoritative source:**
- Direct extraction from Oracle APEX metadata (source of truth)
- Includes search hints and categories for better discovery
- Discovered 1 icon missing from web scraping: `fa-flag-bh`

> **To refresh this list when APEX is upgraded**, use the `/refresh-apex-icons` prompt.

## Icon Categories

Font APEX organizes icons into 38 categories (37 in APEX 24.2 + **CONSTRUCTION** added in APEX 26.1):

| Category | Count | Examples | Version Added |
|---|---|---|---|
| AI | 35 | `fa-ai`, `fa-ai-generative`, `fa-ai-sparkle-*` | ≤ 24.2 |
| BUSINESS | ~50 | `fa-briefcase`, `fa-building`, `fa-handshake-o` | ≤ 24.2 |
| CALENDAR | ~30 | `fa-calendar`, `fa-calendar-o`, `fa-calendar-check-o` | ≤ 24.2 |
| CHART | ~40 | `fa-area-chart`, `fa-bar-chart`, `fa-line-chart` | ≤ 24.2 |
| **CONSTRUCTION** | **50** | **`fa-hard-hat`, `fa-crane`, `fa-hammer`, `fa-safety-vest`** | **26.1 NEW** |
| CURRENCY | ~20 | `fa-dollar`, `fa-euro`, `fa-yen`, `fa-bitcoin` | ≤ 24.2 |
| DIRECTIONAL | ~80 | `fa-arrow-left`, `fa-chevron-right`, `fa-angle-up` | ≤ 24.2 |
| EMOJI | ~10 | `fa-smile-o`, `fa-frown-o`, `fa-meh-o` | ≤ 24.2 |
| FLAG | ~200 | Country flags: `fa-flag-us`, `fa-flag-gb`, `fa-flag-bh` | ≤ 24.2 |
| FORM_CONTROL | ~40 | `fa-check-square`, `fa-radio`, `fa-toggle-on` | ≤ 24.2 |
| MAPS | ~15 | `fa-map`, `fa-map-marker`, `fa-compass` | ≤ 24.2 |
| MEDICAL | ~30 | `fa-stethoscope`, `fa-heartbeat`, `fa-h-square` | ≤ 24.2 |
| TRANSPORTATION | ~20 | `fa-car`, `fa-plane`, `fa-ship` | ≤ 24.2 |
| VIDEO_PLAYER | ~15 | `fa-play`, `fa-pause`, `fa-stop` | ≤ 24.2 |
| WEB_APPLICATION | ~900 | General purpose icons (largest category) | ≤ 24.2 |

## Usage Examples

### In HTML
```html
<span class="fa fa-check"></span>
<span class="fa fa-times-circle-o"></span>
<span class="fa fa-line-chart"></span>
```

### In APEX Badges

For complete badge implementation patterns, see **[apex-badges.md](apex-badges.md)**.

Quick example:
```html
{with/}
    LABEL:=Active
    VALUE:=Active
    LABEL_DISPLAY:=N
    ICON:=fa fa-check
    STYLE:=u-success
{apply THEME$BADGE/}
```

### In APEX Builder
When setting icon properties, use just the icon name:
- `fa-check`
- `fa-times-circle-o`
- `fa-users-cog`

### In Report/IG Columns
```sql
select case status
         when 'ACTIVE'   then 'fa-check-circle'
         when 'INACTIVE' then 'fa-times-circle'
         else 'fa-question-circle'
       end as status_icon,
       case status
         when 'ACTIVE'   then 'u-success'
         when 'INACTIVE' then 'u-danger'
         else 'u-warning'
       end as status_color
  from my_table
```

## Common Use Cases

### AI & Machine Learning
`fa-ai`, `fa-ai-generative`, `fa-ai-innovation-lightbulb`, `fa-ai-microchip`, `fa-ai-prompt`, `fa-ai-sparkle-generate-text`, `fa-ai-sparkle-generate-image`, `fa-ai-sparkle-generate-document`

**Search hints:** ai, brain, smart, generative, prompt, enhance, improve

### Business & Finance
`fa-briefcase`, `fa-building`, `fa-building-o`, `fa-calculator`, `fa-chart-area`, `fa-line-chart`, `fa-handshake-o`, `fa-users`, `fa-users-cog`, `fa-money`, `fa-credit-card`, `fa-shopping-cart`

**Search hints:** business, finance, commerce, sales, team, organization

### Status Indicators
`fa-check-circle` (success), `fa-times-circle` (error), `fa-exclamation-triangle` (warning), `fa-info-circle` (info), `fa-question-circle` (help), `fa-clock-o` (pending), `fa-spinner` (loading)

**Search hints:** status, alert, notification, message

### Common Actions
`fa-check` (confirm), `fa-times` (cancel), `fa-plus` (add), `fa-minus` (reduce), `fa-edit` (edit/pencil), `fa-trash-o` (delete), `fa-save`/`fa-floppy-o` (save), `fa-search` (find), `fa-filter` (filter)

**Search hints:** action, button, control, operation

### Navigation
`fa-home` (home/dashboard), `fa-arrow-left` (back), `fa-arrow-right` (forward), `fa-chevron-left`, `fa-chevron-right`, `fa-bars` (menu), `fa-th` (grid), `fa-list` (list view)

**Search hints:** navigation, menu, arrow, direction

### Charts & Analytics
`fa-area-chart`, `fa-bar-chart`, `fa-line-chart`, `fa-pie-chart`, `fa-analytics`, `fa-dashboard`, `fa-gauge`, `fa-trend-up`, `fa-trend-down`

**Search hints:** chart, graph, analytics, data, visualization

## Commonly Confused Icons (Hallucination Prevention)

| ❌ Incorrect (doesn't exist) | ✅ Correct Font APEX icon |
|---|---|
| `fa-chart-line` | `fa-line-chart` |
| `fa-handshake` | `fa-handshake-o` |
| `fa-file-alt` | `fa-file-text` |
| `fa-crown` | `fa-trophy` (closest alternative) |
| `fa-gear` | `fa-cog` |
| `fa-trash` | `fa-trash-o` |

**Note:** This list includes `fa-flag-bh`, an icon missing from some public icon repositories but present in the official APEX metadata.

## New in APEX 26.1 (50 icons — CONSTRUCTION category)

APEX 26.1 adds a brand-new **CONSTRUCTION** category with 50 icons covering construction equipment, tools, safety gear, materials, and site workers.

| Icon | Category | Search Hints |
|---|---|---|
| `fa-axe` | CONSTRUCTION | tool,chop,wood,cutting,logging |
| `fa-blueprint-construction` | CONSTRUCTION | plan,design,architecture,drawing |
| `fa-bricks` | CONSTRUCTION | wall,building,materials,masonry |
| `fa-brush` | CONSTRUCTION | paint,tool,art,decorating,renovation |
| `fa-bucket` | CONSTRUCTION | paint,water,container,cleaning |
| `fa-bulldozer` | CONSTRUCTION | vehicle,earthmover,machine |
| `fa-compass-drafting` | CONSTRUCTION | design,draw,architecture,engineering,plan |
| `fa-crane` | CONSTRUCTION | lifting,crane,machine,site |
| `fa-crane-hook` | CONSTRUCTION | lifting,hook,equipment,machine |
| `fa-drill` | CONSTRUCTION | tool,boring,hardware,power |
| `fa-dump-truck` | CONSTRUCTION | vehicle,hauling,truck,site |
| `fa-excavator` | CONSTRUCTION | digging,vehicle,earthmoving |
| `fa-faucet` | CONSTRUCTION | plumbing,water,fixture,pipe,hardware |
| `fa-forklift` | CONSTRUCTION | warehouse,vehicle,loading,equipment |
| `fa-hammer` | CONSTRUCTION | tool,nail,repair,carpentry |
| `fa-hammer-brush` | CONSTRUCTION | renovation,tool,repair,painting |
| `fa-hard-hat` | CONSTRUCTION | safety,helmet,gear,worker |
| `fa-ladder` | CONSTRUCTION | climb,tool,repair,access |
| `fa-land-surveying` | CONSTRUCTION | measurement,survey,map,planning |
| `fa-mine-cart` | CONSTRUCTION | mining,cart,ore,underground,transport |
| `fa-mound` | CONSTRUCTION | earth,land,dirt,site |
| `fa-paint-can` | CONSTRUCTION | paint,tool,renovation,decorating,liquid |
| `fa-paint-roller` | CONSTRUCTION | paint,tool,decorating,renovation,wall |
| `fa-paver` | CONSTRUCTION | asphalt,road,vehicle,site |
| `fa-person-digging` | CONSTRUCTION | worker,dig,site |
| `fa-pipe` | CONSTRUCTION | plumbing,water,underground,flow |
| `fa-plexiglass` | CONSTRUCTION | material,barrier,clear,protective |
| `fa-portable-toilet` | CONSTRUCTION | bathroom,sanitation,portable,site |
| `fa-reel` | CONSTRUCTION | cable,electric,cord,tool |
| `fa-roadblock` | CONSTRUCTION | barrier,warning,traffic,site |
| `fa-ruler` | CONSTRUCTION | measure,tool,straight,line,drawing |
| `fa-ruler-combination` | CONSTRUCTION | measure,tool,angle,design,blueprint |
| `fa-safety-vest` | CONSTRUCTION | gear,protection,worker,safety |
| `fa-screwdriver` | CONSTRUCTION | tool,hardware,repair |
| `fa-sheet-metal` | CONSTRUCTION | material,metal,building,industrial |
| `fa-shovel` | CONSTRUCTION | dig,tool,earth |
| `fa-siding` | CONSTRUCTION | house,wall,cladding,exterior |
| `fa-toolbox` | CONSTRUCTION | tools,kit,repair,storage |
| `fa-tower-crane` | CONSTRUCTION | crane,building,skyline,equipment |
| `fa-traffic-cone` | CONSTRUCTION | safety,warning,traffic,barrier |
| `fa-triangle-person-digging` | CONSTRUCTION | warning,sign,digging,worker |
| `fa-trowel` | CONSTRUCTION | tool,masonry,plaster,cement |
| `fa-trowel-bricks` | CONSTRUCTION | masonry,tool,bricklaying,cement |
| `fa-trowel-stucco` | CONSTRUCTION | plaster,tool,finishing,wall |
| `fa-truck-container` | CONSTRUCTION | shipping,logistics,truck,freight,construction |
| `fa-truck-ladder` | CONSTRUCTION | ladder,vehicle,rescue |
| `fa-truck-pickup` | CONSTRUCTION | vehicle,transport,utility,haul |
| `fa-user-worker` | CONSTRUCTION | person,employee,safety |
| `fa-welding-mask` | CONSTRUCTION | safety,welding,mask,gear |
| `fa-wheelbarrow` | CONSTRUCTION | tool,carry,garden |

## Complete Icon Reference (1,539 icons)

| Icon | Category | Search Hints |
|---|---|---|
| `fa-2d-mode` | MAPS | maps,mode,2d,3d |
| `fa-3d-mode` | MAPS | maps,mode,2d,3d |
| `fa-404` | WEB_APPLICATION | broken link,error page |
| `fa-4k` | WEB_APPLICATION |  |
| `fa-abacus` | WEB_APPLICATION | math,mathematics,counting,calculator |
| `fa-accessor-more` | WEB_APPLICATION | programming,network,branch,connection |
| `fa-accessor-one` | WEB_APPLICATION | programming,network,connection |
| `fa-accordion` | WEB_APPLICATION | navigation,menu,list,expand |
| `fa-address-book` | WEB_APPLICATION | contacts |
| `fa-address-book-o` | WEB_APPLICATION | contacts |
| `fa-address-card` | WEB_APPLICATION | vcard |
| `fa-address-card-o` | WEB_APPLICATION | vcard-o |
| `fa-adjust` | WEB_APPLICATION | contrast |
| `fa-ai` | AI | ai,brain,smart |
| `fa-ai-generative` | AI | ai |
| `fa-ai-innovation-lightbulb` | AI | ai,bulb |
| `fa-ai-microchip` | AI | ai,chip |
| `fa-ai-prompt` | AI | ai,prompt |
| `fa-ai-sparkle-enhance-color` | AI | ai,color |
| `fa-ai-sparkle-enlarge` | AI | ai,expand |
| `fa-ai-sparkle-eraser` | AI | ai |
| `fa-ai-sparkle-generate-audio` | AI | ai,sound |
| `fa-ai-sparkle-generate-document` | AI | ai,page |
| `fa-ai-sparkle-generate-image` | AI | ai,photo |
| `fa-ai-sparkle-generate-list` | AI | ai |
| `fa-ai-sparkle-generate-text` | AI | ai |
| `fa-ai-sparkle-improve-text` | AI | ai,cursor |
| `fa-ai-sparkle-message` | AI | ai,chat,comment |
| `fa-ai-sparkle-remove-image-background` | AI | ai,photo,picture |
| `fa-ai-sparkle-scan` | AI | ai |
| `fa-ai-sparkle-select` | AI | ai,box |
| `fa-ai-sparkle-token` | AI | ai,square,box,block |
| `fa-ai-sparkle-zoom-in` | AI | ai,magnify,enlarge,bigger |
| `fa-ai-sparkle-zoom-out` | AI | ai,minify,smaller |
| `fa-ai-square` | AI | ai,box,block |
| `fa-alarm-check` | WEB_APPLICATION | time |
| `fa-alarm-clock` | WEB_APPLICATION | time |
| `fa-alarm-minus` | WEB_APPLICATION | time |
| `fa-alarm-plus` | WEB_APPLICATION | time |
| `fa-alarm-snooze` | WEB_APPLICATION | time |
| `fa-alarm-times` | WEB_APPLICATION | time |
| `fa-alert` | WEB_APPLICATION | message,comment |
| `fa-align-center` | TEXT_EDITOR | middle,text |
| `fa-align-justify` | TEXT_EDITOR | text |
| `fa-align-left` | TEXT_EDITOR | text |
| `fa-align-right` | TEXT_EDITOR | text |
| `fa-ambulance` | MEDICAL:TRANSPORTATION | support,help |
| `fa-american-sign-language-interpreting` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-analytics` | WEB_APPLICATION | analyze,magnifying glass,search,arrow,up |
| `fa-anchor` | WEB_APPLICATION | link |
| `fa-angle-double-down` | DIRECTIONAL |  |
| `fa-angle-double-left` | DIRECTIONAL | laquo,quote,previous,back |
| `fa-angle-double-right` | DIRECTIONAL | raquo,quote,next,forward |
| `fa-angle-double-up` | DIRECTIONAL |  |
| `fa-angle-down` | DIRECTIONAL |  |
| `fa-angle-left` | DIRECTIONAL | previous,back |
| `fa-angle-right` | DIRECTIONAL | next,forward |
| `fa-angle-up` | DIRECTIONAL |  |
| `fa-apex` | WEB_APPLICATION | applicationexpress,htmldb,webdb |
| `fa-apex-square` | WEB_APPLICATION | applicationexpress,htmldb,webdb |
| `fa-archive` | WEB_APPLICATION | box,storage |
| `fa-area-chart` | WEB_APPLICATION:CHART | graph,analytics |
| `fa-arrow-circle-down` | DIRECTIONAL | download |
| `fa-arrow-circle-left` | DIRECTIONAL | previous,back |
| `fa-arrow-circle-o-down` | DIRECTIONAL | download |
| `fa-arrow-circle-o-left` | DIRECTIONAL | previous,back |
| `fa-arrow-circle-o-right` | DIRECTIONAL | next,forward |
| `fa-arrow-circle-o-up` | DIRECTIONAL |  |
| `fa-arrow-circle-right` | DIRECTIONAL | next,forward |
| `fa-arrow-circle-up` | DIRECTIONAL |  |
| `fa-arrow-down` | DIRECTIONAL | download |
| `fa-arrow-down-alt` | DIRECTIONAL |  |
| `fa-arrow-down-left-alt` | DIRECTIONAL |  |
| `fa-arrow-down-right-alt` | DIRECTIONAL |  |
| `fa-arrow-left` | DIRECTIONAL | previous,back |
| `fa-arrow-left-alt` | DIRECTIONAL |  |
| `fa-arrow-right` | DIRECTIONAL | next,forward |
| `fa-arrow-right-alt` | DIRECTIONAL |  |
| `fa-arrow-up` | DIRECTIONAL |  |
| `fa-arrow-up-alt` | DIRECTIONAL |  |
| `fa-arrow-up-left-alt` | DIRECTIONAL |  |
| `fa-arrow-up-right-alt` | DIRECTIONAL |  |
| `fa-arrows` | WEB_APPLICATION:DIRECTIONAL | move,reorder,resize |
| `fa-arrows-alt` | VIDEO_PLAYER:DIRECTIONAL | expand,enlarge,fullscreen,bigger,move,reorder,resize |
| `fa-arrows-h` | WEB_APPLICATION:DIRECTIONAL | resize |
| `fa-arrows-v` | WEB_APPLICATION:DIRECTIONAL | resize |
| `fa-asl-interpreting` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-assistive-listening-systems` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-asterisk` | WEB_APPLICATION | details |
| `fa-at` | WEB_APPLICATION |  |
| `fa-audio-description` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-awesome-face` | EMOJI |  |
| `fa-backward` | VIDEO_PLAYER | rewind,previous |
| `fa-badge` | WEB_APPLICATION | status |
| `fa-badge-check` | WEB_APPLICATION | status |
| `fa-badge-dollar` | WEB_APPLICATION | status |
| `fa-badge-list` | WEB_APPLICATION |  |
| `fa-badge-percent` | WEB_APPLICATION | status |
| `fa-badgerine` | EMOJI | comedian,superhero,allan |
| `fa-badges` | WEB_APPLICATION |  |
| `fa-balance-scale` | WEB_APPLICATION |  |
| `fa-ban` | WEB_APPLICATION | delete,remove,trash,hide,block,stop,abort,cancel |
| `fa-bar-chart` | WEB_APPLICATION:CHART | barcharto,graph,analytics |
| `fa-bar-chart-horizontal` | CHART |  |
| `fa-barcode` | WEB_APPLICATION | scan |
| `fa-barcode-read` | BUSINESS | scan |
| `fa-bars` | WEB_APPLICATION | navicon,reorder,menu,drag,reorder,settings,list,ul,ol,checklist,todo,list,hamburger |
| `fa-bath` | WEB_APPLICATION | bathtub |
| `fa-battery-0` | WEB_APPLICATION | empty |
| `fa-battery-1` | WEB_APPLICATION | quarter |
| `fa-battery-2` | WEB_APPLICATION | half |
| `fa-battery-3` | WEB_APPLICATION | three quarters |
| `fa-battery-4` | WEB_APPLICATION | full |
| `fa-battleship` | WEB_APPLICATION |  |
| `fa-bed` | WEB_APPLICATION | travel,hotel |
| `fa-beer` | WEB_APPLICATION | alcohol,stein,drink,mug,bar,liquor |
| `fa-bell` | WEB_APPLICATION | alert,reminder,notification |
| `fa-bell-o` | WEB_APPLICATION | alert,reminder,notification |
| `fa-bell-slash` | WEB_APPLICATION |  |
| `fa-bell-slash-o` | WEB_APPLICATION |  |
| `fa-bicycle` | WEB_APPLICATION:TRANSPORTATION | vehicle,bike |
| `fa-binoculars` | WEB_APPLICATION |  |
| `fa-biohazard` | MEDICAL | danger,waste |
| `fa-birthday-cake` | WEB_APPLICATION |  |
| `fa-bitcoin` | CURRENCY |  |
| `fa-blind` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-bold` | TEXT_EDITOR |  |
| `fa-bolt` | WEB_APPLICATION | lightning,weather,flash |
| `fa-bomb` | WEB_APPLICATION |  |
| `fa-book` | WEB_APPLICATION | read,documentation |
| `fa-bookmark` | WEB_APPLICATION | save |
| `fa-bookmark-o` | WEB_APPLICATION | save |
| `fa-box-arrow-in-east` | DIRECTIONAL |  |
| `fa-box-arrow-in-ne` | DIRECTIONAL |  |
| `fa-box-arrow-in-north` | DIRECTIONAL |  |
| `fa-box-arrow-in-nw` | DIRECTIONAL |  |
| `fa-box-arrow-in-se` | DIRECTIONAL |  |
| `fa-box-arrow-in-south` | DIRECTIONAL |  |
| `fa-box-arrow-in-sw` | DIRECTIONAL |  |
| `fa-box-arrow-in-west` | DIRECTIONAL |  |
| `fa-box-arrow-out-east` | DIRECTIONAL |  |
| `fa-box-arrow-out-ne` | DIRECTIONAL |  |
| `fa-box-arrow-out-north` | DIRECTIONAL |  |
| `fa-box-arrow-out-nw` | DIRECTIONAL |  |
| `fa-box-arrow-out-se` | DIRECTIONAL |  |
| `fa-box-arrow-out-south` | DIRECTIONAL |  |
| `fa-box-arrow-out-sw` | DIRECTIONAL |  |
| `fa-box-arrow-out-west` | DIRECTIONAL |  |
| `fa-box-plot-chart` | CHART |  |
| `fa-braille` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-breadcrumb` | WEB_APPLICATION | navigation |
| `fa-briefcase` | WEB_APPLICATION | work,business,office,luggage,bag |
| `fa-btc` | CURRENCY |  |
| `fa-bubble-chart` | CHART |  |
| `fa-bug` | WEB_APPLICATION | report,insect |
| `fa-bug-slash` | WEB_APPLICATION | insect |
| `fa-building` | WEB_APPLICATION | work,business,apartment,office,company |
| `fa-building-o` | WEB_APPLICATION | work,business,apartment,office,company |
| `fa-bullhorn` | WEB_APPLICATION | announcement,share,broadcast,louder |
| `fa-bullseye` | WEB_APPLICATION | target |
| `fa-bus` | WEB_APPLICATION:TRANSPORTATION | vehicle |
| `fa-button` | WEB_APPLICATION |  |
| `fa-button-container` | WEB_APPLICATION | region |
| `fa-button-group` | WEB_APPLICATION | pill |
| `fa-calculator` | WEB_APPLICATION |  |
| `fa-calendar` | WEB_APPLICATION | date,time,when |
| `fa-calendar-alarm` | CALENDAR |  |
| `fa-calendar-arrow-down` | CALENDAR |  |
| `fa-calendar-arrow-up` | CALENDAR |  |
| `fa-calendar-ban` | CALENDAR |  |
| `fa-calendar-chart` | CALENDAR |  |
| `fa-calendar-check-o` | WEB_APPLICATION |  |
| `fa-calendar-clock` | CALENDAR | history |
| `fa-calendar-day` | CALENDAR |  |
| `fa-calendar-edit` | CALENDAR | pencil |
| `fa-calendar-heart` | CALENDAR | like,favorite |
| `fa-calendar-lock` | CALENDAR |  |
| `fa-calendar-minus-o` | WEB_APPLICATION |  |
| `fa-calendar-month` | CALENDAR |  |
| `fa-calendar-o` | WEB_APPLICATION | date,time,when |
| `fa-calendar-plus-o` | WEB_APPLICATION |  |
| `fa-calendar-pointer` | CALENDAR |  |
| `fa-calendar-search` | CALENDAR |  |
| `fa-calendar-times-o` | WEB_APPLICATION |  |
| `fa-calendar-today` | CALENDAR |  |
| `fa-calendar-user` | CALENDAR |  |
| `fa-calendar-week` | CALENDAR |  |
| `fa-calendar-wrench` | CALENDAR |  |
| `fa-camera` | WEB_APPLICATION | photo,picture,record |
| `fa-camera-retro` | WEB_APPLICATION | photo,picture,record |
| `fa-car` | WEB_APPLICATION:TRANSPORTATION | automobile,vehicle |
| `fa-card-holder` | BUSINESS | wallet |
| `fa-cards` | WEB_APPLICATION | blocks |
| `fa-caret-down` | DIRECTIONAL | more,dropdown,menu,triangledown |
| `fa-caret-left` | DIRECTIONAL | previous,back,triangleleft |
| `fa-caret-right` | DIRECTIONAL | next,forward,triangleright |
| `fa-caret-square-o-down` | WEB_APPLICATION:DIRECTIONAL | toggledown,more,dropdown,menu |
| `fa-caret-square-o-left` | WEB_APPLICATION:DIRECTIONAL | previous,back,toggleleft |
| `fa-caret-square-o-right` | WEB_APPLICATION:DIRECTIONAL | next,forward,toggleright |
| `fa-caret-square-o-up` | WEB_APPLICATION:DIRECTIONAL | toggleup |
| `fa-caret-up` | DIRECTIONAL | triangleup |
| `fa-carousel` | WEB_APPLICATION | slideshow |
| `fa-cart-arrow-down` | WEB_APPLICATION | shopping |
| `fa-cart-arrow-up` | WEB_APPLICATION |  |
| `fa-cart-check` | WEB_APPLICATION |  |
| `fa-cart-edit` | WEB_APPLICATION | pencil |
| `fa-cart-empty` | WEB_APPLICATION |  |
| `fa-cart-full` | WEB_APPLICATION |  |
| `fa-cart-heart` | WEB_APPLICATION | like,favorite |
| `fa-cart-lock` | WEB_APPLICATION |  |
| `fa-cart-magnifying-glass` | WEB_APPLICATION |  |
| `fa-cart-plus` | WEB_APPLICATION | add,shopping |
| `fa-cart-times` | WEB_APPLICATION |  |
| `fa-cash-register` | BUSINESS | money,payment |
| `fa-cc` | WEB_APPLICATION |  |
| `fa-certificate` | WEB_APPLICATION | badge,star |
| `fa-change-case` | WEB_APPLICATION | lowercase,uppercase |
| `fa-chatbot` | AI | ai,chat,robot,assistant |
| `fa-check` | WEB_APPLICATION | checkmark,done,todo,agree,accept,confirm,tick |
| `fa-check-circle` | WEB_APPLICATION | todo,done,agree,accept,confirm |
| `fa-check-circle-o` | WEB_APPLICATION | todo,done,agree,accept,confirm |
| `fa-check-square` | WEB_APPLICATION:FORM_CONTROL | checkmark,done,todo,agree,accept,confirm |
| `fa-check-square-o` | WEB_APPLICATION:FORM_CONTROL | todo,done,agree,accept,confirm |
| `fa-chevron-circle-down` | DIRECTIONAL | more,dropdown,menu |
| `fa-chevron-circle-left` | DIRECTIONAL | previous,back |
| `fa-chevron-circle-right` | DIRECTIONAL | next,forward |
| `fa-chevron-circle-up` | DIRECTIONAL |  |
| `fa-chevron-down` | DIRECTIONAL |  |
| `fa-chevron-left` | DIRECTIONAL | bracket,previous,back |
| `fa-chevron-right` | DIRECTIONAL | bracket,next,forward |
| `fa-chevron-up` | DIRECTIONAL |  |
| `fa-child` | WEB_APPLICATION |  |
| `fa-circle` | WEB_APPLICATION:FORM_CONTROL | dot,notification |
| `fa-circle-0-8` | WEB_APPLICATION |  |
| `fa-circle-1-8` | WEB_APPLICATION |  |
| `fa-circle-2-8` | WEB_APPLICATION |  |
| `fa-circle-3-8` | WEB_APPLICATION |  |
| `fa-circle-4-8` | WEB_APPLICATION |  |
| `fa-circle-5-8` | WEB_APPLICATION |  |
| `fa-circle-6-8` | WEB_APPLICATION |  |
| `fa-circle-7-8` | WEB_APPLICATION |  |
| `fa-circle-8-8` | WEB_APPLICATION |  |
| `fa-circle-arrow-in-east` | DIRECTIONAL |  |
| `fa-circle-arrow-in-ne` | DIRECTIONAL |  |
| `fa-circle-arrow-in-north` | DIRECTIONAL |  |
| `fa-circle-arrow-in-nw` | DIRECTIONAL |  |
| `fa-circle-arrow-in-se` | DIRECTIONAL |  |
| `fa-circle-arrow-in-south` | DIRECTIONAL |  |
| `fa-circle-arrow-in-sw` | DIRECTIONAL |  |
| `fa-circle-arrow-in-west` | DIRECTIONAL |  |
| `fa-circle-arrow-out-east` | DIRECTIONAL |  |
| `fa-circle-arrow-out-ne` | DIRECTIONAL |  |
| `fa-circle-arrow-out-north` | DIRECTIONAL |  |
| `fa-circle-arrow-out-nw` | DIRECTIONAL |  |
| `fa-circle-arrow-out-se` | DIRECTIONAL |  |
| `fa-circle-arrow-out-south` | DIRECTIONAL |  |
| `fa-circle-arrow-out-sw` | DIRECTIONAL |  |
| `fa-circle-arrow-out-west` | DIRECTIONAL |  |
| `fa-circle-o` | WEB_APPLICATION:FORM_CONTROL |  |
| `fa-circle-o-notch` | WEB_APPLICATION:SPINNER |  |
| `fa-circle-thin` | WEB_APPLICATION |  |
| `fa-city` | BUSINESS | building |
| `fa-clipboard` | TEXT_EDITOR | copy,paste |
| `fa-clipboard-arrow-down` | TEXT_EDITOR |  |
| `fa-clipboard-arrow-up` | TEXT_EDITOR |  |
| `fa-clipboard-ban` | TEXT_EDITOR |  |
| `fa-clipboard-bookmark` | TEXT_EDITOR |  |
| `fa-clipboard-chart ` | TEXT_EDITOR |  |
| `fa-clipboard-check` | TEXT_EDITOR |  |
| `fa-clipboard-check-alt` | TEXT_EDITOR |  |
| `fa-clipboard-clock` | TEXT_EDITOR |  |
| `fa-clipboard-edit` | TEXT_EDITOR |  |
| `fa-clipboard-heart` | TEXT_EDITOR |  |
| `fa-clipboard-list` | TEXT_EDITOR |  |
| `fa-clipboard-lock` | TEXT_EDITOR |  |
| `fa-clipboard-new` | TEXT_EDITOR |  |
| `fa-clipboard-plus` | TEXT_EDITOR |  |
| `fa-clipboard-pointer` | TEXT_EDITOR |  |
| `fa-clipboard-search` | TEXT_EDITOR |  |
| `fa-clipboard-user` | TEXT_EDITOR |  |
| `fa-clipboard-wrench` | TEXT_EDITOR |  |
| `fa-clipboard-x` | TEXT_EDITOR |  |
| `fa-clock-o` | WEB_APPLICATION | watch,timer,late,timestamp |
| `fa-clone` | WEB_APPLICATION | copy |
| `fa-cloud` | WEB_APPLICATION | save |
| `fa-cloud-arrow-down` | WEB_APPLICATION |  |
| `fa-cloud-arrow-up` | WEB_APPLICATION |  |
| `fa-cloud-ban` | WEB_APPLICATION |  |
| `fa-cloud-bookmark` | WEB_APPLICATION |  |
| `fa-cloud-chart` | WEB_APPLICATION |  |
| `fa-cloud-check` | WEB_APPLICATION |  |
| `fa-cloud-clock` | WEB_APPLICATION | history |
| `fa-cloud-cursor` | WEB_APPLICATION |  |
| `fa-cloud-download` | WEB_APPLICATION | import |
| `fa-cloud-edit` | WEB_APPLICATION | pencil |
| `fa-cloud-file` | WEB_APPLICATION |  |
| `fa-cloud-heart` | WEB_APPLICATION | like,favorite |
| `fa-cloud-lock` | WEB_APPLICATION |  |
| `fa-cloud-new` | WEB_APPLICATION |  |
| `fa-cloud-play` | WEB_APPLICATION |  |
| `fa-cloud-plus` | WEB_APPLICATION |  |
| `fa-cloud-pointer` | WEB_APPLICATION |  |
| `fa-cloud-search` | WEB_APPLICATION |  |
| `fa-cloud-upload` | WEB_APPLICATION | import |
| `fa-cloud-user` | WEB_APPLICATION |  |
| `fa-cloud-wrench` | WEB_APPLICATION |  |
| `fa-cloud-x` | WEB_APPLICATION | delete,remove |
| `fa-cny` | CURRENCY | china,renminbi,yuan |
| `fa-code` | WEB_APPLICATION | html,brackets |
| `fa-code-fork` | WEB_APPLICATION | git,fork,vcs,svn,github,rebase,version,merge |
| `fa-code-group` | WEB_APPLICATION | group,overlap |
| `fa-coffee` | WEB_APPLICATION | morning,mug,breakfast,tea,drink,cafe |
| `fa-coins` | BUSINESS | payment,money |
| `fa-collapsible` | WEB_APPLICATION |  |
| `fa-columns` | TEXT_EDITOR | split,panes |
| `fa-combo-chart` | CHART |  |
| `fa-comment` | WEB_APPLICATION | speech,notification,note,chat,bubble,feedback |
| `fa-comment-o` | WEB_APPLICATION | notification,note |
| `fa-commenting` | WEB_APPLICATION |  |
| `fa-commenting-o` | WEB_APPLICATION |  |
| `fa-comments` | WEB_APPLICATION | conversation,notification,notes |
| `fa-comments-o` | WEB_APPLICATION | conversation,notification,notes |
| `fa-compass` | WEB_APPLICATION | safari,directory,menu,location |
| `fa-compress` | VIDEO_PLAYER | collapse,combine,contract,merge,smaller |
| `fa-contacts` | WEB_APPLICATION |  |
| `fa-copy` | TEXT_EDITOR | duplicate,copy |
| `fa-copyright` | WEB_APPLICATION |  |
| `fa-creative-commons` | WEB_APPLICATION |  |
| `fa-credit-card` | WEB_APPLICATION:PAYMENT | money,buy,debit,checkout,purchase,payment |
| `fa-credit-card-alt` | WEB_APPLICATION:PAYMENT |  |
| `fa-credit-card-front` | BUSINESS | card,payment |
| `fa-credit-card-terminal` | PAYMENT:WEB_APPLICATION |  |
| `fa-crop` | WEB_APPLICATION |  |
| `fa-crosshairs` | WEB_APPLICATION | picker |
| `fa-cube` | WEB_APPLICATION |  |
| `fa-cubes` | WEB_APPLICATION |  |
| `fa-cut` | TEXT_EDITOR | scissors |
| `fa-cutlery` | WEB_APPLICATION | food,restaurant,spoon,knife,dinner,eat |
| `fa-dashboard` | WEB_APPLICATION | tachometer |
| `fa-database` | WEB_APPLICATION |  |
| `fa-database-application` | WEB_APPLICATION | database |
| `fa-database-arrow-down` | WEB_APPLICATION |  |
| `fa-database-arrow-up` | WEB_APPLICATION |  |
| `fa-database-ban` | WEB_APPLICATION |  |
| `fa-database-bookmark` | WEB_APPLICATION |  |
| `fa-database-chart` | WEB_APPLICATION |  |
| `fa-database-check` | WEB_APPLICATION |  |
| `fa-database-clock` | WEB_APPLICATION | history |
| `fa-database-cursor` | WEB_APPLICATION |  |
| `fa-database-edit` | WEB_APPLICATION | pencil |
| `fa-database-file` | WEB_APPLICATION |  |
| `fa-database-heart` | WEB_APPLICATION | like,favorite |
| `fa-database-lock` | WEB_APPLICATION |  |
| `fa-database-new` | WEB_APPLICATION |  |
| `fa-database-play` | WEB_APPLICATION |  |
| `fa-database-plus` | WEB_APPLICATION |  |
| `fa-database-pointer` | WEB_APPLICATION |  |
| `fa-database-search` | WEB_APPLICATION |  |
| `fa-database-user` | WEB_APPLICATION |  |
| `fa-database-wrench` | WEB_APPLICATION |  |
| `fa-database-x` | WEB_APPLICATION | delete,remove |
| `fa-dataset` | AI |  |
| `fa-deaf` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-deafness` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-design` | WEB_APPLICATION |  |
| `fa-desktop` | WEB_APPLICATION | monitor,screen,desktop,computer,demo,device |
| `fa-dial-gauge-chart` | CHART |  |
| `fa-diamond` | WEB_APPLICATION | gem,gemstone |
| `fa-dollar` | CURRENCY | usd |
| `fa-donut-chart` | CHART |  |
| `fa-dot-circle-o` | WEB_APPLICATION:FORM_CONTROL | target,bullseye,notification |
| `fa-download` | WEB_APPLICATION | import |
| `fa-download-alt` | WEB_APPLICATION |  |
| `fa-drone` | AI | robot |
| `fa-dynamic-content` | WEB_APPLICATION |  |
| `fa-edit` | WEB_APPLICATION | write,edit,update |
| `fa-eject` | VIDEO_PLAYER |  |
| `fa-ellipsis-h` | WEB_APPLICATION | dots |
| `fa-ellipsis-h-o` | WEB_APPLICATION |  |
| `fa-ellipsis-v` | WEB_APPLICATION | dots |
| `fa-ellipsis-v-o` | WEB_APPLICATION |  |
| `fa-emoji-angry` | EMOJI |  |
| `fa-emoji-astonished` | EMOJI |  |
| `fa-emoji-big-eyes-smile` | EMOJI |  |
| `fa-emoji-big-frown` | EMOJI |  |
| `fa-emoji-cold-sweat` | EMOJI |  |
| `fa-emoji-confounded` | EMOJI |  |
| `fa-emoji-confused` | EMOJI |  |
| `fa-emoji-cool` | EMOJI |  |
| `fa-emoji-cringe` | EMOJI |  |
| `fa-emoji-cry` | EMOJI |  |
| `fa-emoji-delicious` | EMOJI |  |
| `fa-emoji-disappointed` | EMOJI |  |
| `fa-emoji-disappointed-relieved` | EMOJI |  |
| `fa-emoji-expressionless` | EMOJI |  |
| `fa-emoji-fearful` | EMOJI |  |
| `fa-emoji-frown` | EMOJI |  |
| `fa-emoji-grimace` | EMOJI |  |
| `fa-emoji-grin-sweat` | EMOJI |  |
| `fa-emoji-happy-smile` | EMOJI |  |
| `fa-emoji-hushed` | EMOJI |  |
| `fa-emoji-laughing` | EMOJI |  |
| `fa-emoji-lol` | EMOJI |  |
| `fa-emoji-love` | EMOJI |  |
| `fa-emoji-mean` | EMOJI |  |
| `fa-emoji-nerd` | EMOJI |  |
| `fa-emoji-neutral` | EMOJI |  |
| `fa-emoji-no-mouth` | EMOJI |  |
| `fa-emoji-open-mouth` | EMOJI |  |
| `fa-emoji-pensive` | EMOJI |  |
| `fa-emoji-persevere` | EMOJI |  |
| `fa-emoji-pleased` | EMOJI |  |
| `fa-emoji-relieved` | EMOJI |  |
| `fa-emoji-rotfl` | EMOJI |  |
| `fa-emoji-scream` | EMOJI |  |
| `fa-emoji-sleeping` | EMOJI |  |
| `fa-emoji-sleepy` | EMOJI |  |
| `fa-emoji-slight-frown` | EMOJI |  |
| `fa-emoji-slight-smile` | EMOJI |  |
| `fa-emoji-smile` | EMOJI |  |
| `fa-emoji-smirk` | EMOJI |  |
| `fa-emoji-stuck-out-tongue` | EMOJI |  |
| `fa-emoji-stuck-out-tongue-closed-eyes` | EMOJI |  |
| `fa-emoji-stuck-out-tongue-wink` | EMOJI |  |
| `fa-emoji-sweet-smile` | EMOJI |  |
| `fa-emoji-tired` | EMOJI |  |
| `fa-emoji-unamused` | EMOJI |  |
| `fa-emoji-upside-down` | EMOJI |  |
| `fa-emoji-weary` | EMOJI |  |
| `fa-emoji-wink` | EMOJI |  |
| `fa-emoji-worry` | EMOJI |  |
| `fa-emoji-zipper-mouth` | EMOJI |  |
| `fa-envelope` | WEB_APPLICATION | email,email,letter,support,mail,notification |
| `fa-envelope-arrow-down` | WEB_APPLICATION |  |
| `fa-envelope-arrow-up` | WEB_APPLICATION |  |
| `fa-envelope-ban` | WEB_APPLICATION |  |
| `fa-envelope-bookmark` | WEB_APPLICATION |  |
| `fa-envelope-chart` | WEB_APPLICATION |  |
| `fa-envelope-check` | WEB_APPLICATION |  |
| `fa-envelope-clock` | WEB_APPLICATION | history |
| `fa-envelope-cursor` | WEB_APPLICATION |  |
| `fa-envelope-edit` | WEB_APPLICATION | pencil |
| `fa-envelope-heart` | WEB_APPLICATION | like,favorite |
| `fa-envelope-lock` | WEB_APPLICATION |  |
| `fa-envelope-o` | WEB_APPLICATION | email,support,email,letter,mail,notification |
| `fa-envelope-open` | WEB_APPLICATION | mail |
| `fa-envelope-open-o` | WEB_APPLICATION |  |
| `fa-envelope-play` | WEB_APPLICATION |  |
| `fa-envelope-plus` | WEB_APPLICATION |  |
| `fa-envelope-pointer` | WEB_APPLICATION |  |
| `fa-envelope-search` | WEB_APPLICATION |  |
| `fa-envelope-square` | WEB_APPLICATION |  |
| `fa-envelope-user` | WEB_APPLICATION |  |
| `fa-envelope-wrench` | WEB_APPLICATION |  |
| `fa-envelope-x` | WEB_APPLICATION | delete,remove |
| `fa-eraser` | TEXT_EDITOR:WEB_APPLICATION |  |
| `fa-eur` | CURRENCY | euro |
| `fa-euro` | CURRENCY | euro |
| `fa-exception` | WEB_APPLICATION | warning,error |
| `fa-exchange` | WEB_APPLICATION:DIRECTIONAL | transfer,arrows |
| `fa-exclamation` | WEB_APPLICATION | warning,error,problem,notification,notify,alert |
| `fa-exclamation-circle` | WEB_APPLICATION | warning,error,problem,notification,alert |
| `fa-exclamation-circle-o` | WEB_APPLICATION | warning,error,problem,notification,alert |
| `fa-exclamation-diamond` | WEB_APPLICATION | warning,error,problem,notification,alert,warning |
| `fa-exclamation-diamond-o` | WEB_APPLICATION | warning,error,problem,notification,alert,warning |
| `fa-exclamation-square` | WEB_APPLICATION | warning,error,problem,notification,alert,warning |
| `fa-exclamation-square-o` | WEB_APPLICATION | warning,error,problem,notification,alert,warning |
| `fa-exclamation-triangle` | WEB_APPLICATION | warning,error,problem,notification,alert,warning |
| `fa-exclamation-triangle-o` | WEB_APPLICATION | warning,error,problem,notification,alert,warning |
| `fa-expand` | VIDEO_PLAYER | enlarge,bigger,resize |
| `fa-expand-collapse` | WEB_APPLICATION | plus,minus |
| `fa-external-link` | WEB_APPLICATION | open,new |
| `fa-external-link-square` | WEB_APPLICATION | open,new |
| `fa-eye` | WEB_APPLICATION | show,visible,views |
| `fa-eye-slash` | WEB_APPLICATION | toggle,show,hide,visible,visiblity,views |
| `fa-eyedropper` | WEB_APPLICATION |  |
| `fa-fast-backward` | VIDEO_PLAYER | rewind,previous,beginning,start,first |
| `fa-fast-forward` | VIDEO_PLAYER | next,end,last |
| `fa-fax` | WEB_APPLICATION |  |
| `fa-feed` | WEB_APPLICATION | blog,rss |
| `fa-female` | WEB_APPLICATION | woman,user,person,profile |
| `fa-fighter-jet` | WEB_APPLICATION:TRANSPORTATION | fly,plane,airplane,quick,fast,travel |
| `fa-fighter-jet-alt` | WEB_APPLICATION | plane |
| `fa-file` | TEXT_EDITOR:FILE_TYPE | new,page,pdf,document |
| `fa-file-archive-o` | WEB_APPLICATION:FILE_TYPE | zip |
| `fa-file-arrow-down` | WEB_APPLICATION |  |
| `fa-file-arrow-up` | WEB_APPLICATION |  |
| `fa-file-audio-o` | WEB_APPLICATION:FILE_TYPE | sound |
| `fa-file-ban` | WEB_APPLICATION |  |
| `fa-file-bookmark` | WEB_APPLICATION |  |
| `fa-file-brackets` | WEB_APPLICATION | programming,code |
| `fa-file-cabinet` | BUSINESS |  |
| `fa-file-chart` | WEB_APPLICATION |  |
| `fa-file-check` | WEB_APPLICATION |  |
| `fa-file-clock` | WEB_APPLICATION | history |
| `fa-file-code-o` | WEB_APPLICATION:FILE_TYPE |  |
| `fa-file-csv-o` | WEB_APPLICATION | programming,code |
| `fa-file-cursor` | WEB_APPLICATION |  |
| `fa-file-edit` | WEB_APPLICATION | pencil |
| `fa-file-excel-o` | WEB_APPLICATION:FILE_TYPE |  |
| `fa-file-heart` | WEB_APPLICATION | like,favorite |
| `fa-file-image-o` | WEB_APPLICATION:FILE_TYPE | photo,picture |
| `fa-file-json-o` | WEB_APPLICATION | programming,code |
| `fa-file-lock` | WEB_APPLICATION |  |
| `fa-file-medical` | MEDICAL |  |
| `fa-file-new` | WEB_APPLICATION |  |
| `fa-file-o` | TEXT_EDITOR:FILE_TYPE | new,page,pdf,document |
| `fa-file-pdf-o` | WEB_APPLICATION:FILE_TYPE |  |
| `fa-file-play` | WEB_APPLICATION |  |
| `fa-file-plus` | WEB_APPLICATION |  |
| `fa-file-pointer` | WEB_APPLICATION |  |
| `fa-file-powerpoint-o` | WEB_APPLICATION:FILE_TYPE |  |
| `fa-file-prescription` | MEDICAL | drug,medicine |
| `fa-file-search` | WEB_APPLICATION |  |
| `fa-file-signature` | WEB_APPLICATION | sign,authorized,contract |
| `fa-file-sql-o` | WEB_APPLICATION:FILE_TYPE |  |
| `fa-file-text` | TEXT_EDITOR:FILE_TYPE | new,page,pdf,document |
| `fa-file-text-o` | TEXT_EDITOR:FILE_TYPE | new,page,pdf,document |
| `fa-file-user` | WEB_APPLICATION |  |
| `fa-file-video-o` | WEB_APPLICATION:FILE_TYPE | filemovieo |
| `fa-file-word-o` | WEB_APPLICATION:FILE_TYPE |  |
| `fa-file-wrench` | WEB_APPLICATION |  |
| `fa-file-x` | WEB_APPLICATION | delete,remove |
| `fa-files-o` | TEXT_EDITOR | duplicate,copy |
| `fa-film` | WEB_APPLICATION | movie |
| `fa-filter` | WEB_APPLICATION | funnel,options |
| `fa-fire` | WEB_APPLICATION | flame,hot,popular |
| `fa-fire-extinguisher` | WEB_APPLICATION |  |
| `fa-fit-to-height` | WEB_APPLICATION |  |
| `fa-fit-to-size` | WEB_APPLICATION |  |
| `fa-fit-to-width` | WEB_APPLICATION |  |
| `fa-flag` | WEB_APPLICATION | report,notification,notify |
| `fa-flag-ad` | FLAG | andorra |
| `fa-flag-ae` | FLAG | united,arab,emirates |
| `fa-flag-af` | FLAG | afghanistan |
| `fa-flag-ag` | FLAG | antigua,barbuda |
| `fa-flag-ai` | FLAG | anguilla |
| `fa-flag-al` | FLAG | albania |
| `fa-flag-am` | FLAG | armenia |
| `fa-flag-an` | FLAG | netherlands,antilles |
| `fa-flag-ao` | FLAG | angola |
| `fa-flag-aq` | FLAG | antartica |
| `fa-flag-ar` | FLAG | argentina |
| `fa-flag-as` | FLAG | american,samoa |
| `fa-flag-at` | FLAG | austria |
| `fa-flag-au` | FLAG | australia |
| `fa-flag-aw` | FLAG | aruba |
| `fa-flag-ax` | FLAG | aland,islands |
| `fa-flag-az` | FLAG | azerbaijan |
| `fa-flag-ba` | FLAG | bosnia,herzegovina |
| `fa-flag-bb` | FLAG | barbados |
| `fa-flag-bd` | FLAG | bangladesh |
| `fa-flag-be` | FLAG | belgium |
| `fa-flag-bf` | FLAG | burkina,faso |
| `fa-flag-bg` | FLAG | bulgaria |
| `fa-flag-bh` | FLAG | bahrain |
| `fa-flag-bi` | FLAG | burundi |
| `fa-flag-bj` | FLAG | benin |
| `fa-flag-bl` | FLAG | saint,barthelemy |
| `fa-flag-bm` | FLAG | bermuda |
| `fa-flag-bn` | FLAG | brunei |
| `fa-flag-bo` | FLAG | bolivia |
| `fa-flag-bq` | FLAG | bonaire,sint,eustatius,saba |
| `fa-flag-br` | FLAG | brazil |
| `fa-flag-bs` | FLAG | bahamas |
| `fa-flag-bt` | FLAG | bhutan |
| `fa-flag-bv` | FLAG | bouvet,island |
| `fa-flag-bw` | FLAG | botswana |
| `fa-flag-by` | FLAG | belarus |
| `fa-flag-bz` | FLAG | belize |
| `fa-flag-ca` | FLAG | canada |
| `fa-flag-cc` | FLAG | cocos,islands,keeling |
| `fa-flag-cd` | FLAG | democratic,republic,congo |
| `fa-flag-cf` | FLAG | central,african,republic |
| `fa-flag-cg` | FLAG | republic,congo |
| `fa-flag-ch` | FLAG | switzerland |
| `fa-flag-checkered` | WEB_APPLICATION | report,notification,notify |
| `fa-flag-ci` | FLAG | cote,ivoire |
| `fa-flag-ck` | FLAG | cook,islands |
| `fa-flag-cl` | FLAG | chile |
| `fa-flag-cm` | FLAG | cameroon |
| `fa-flag-cn` | FLAG | china |
| `fa-flag-co` | FLAG | colombia |
| `fa-flag-cr` | FLAG | costa,rica |
| `fa-flag-cu` | FLAG | cuba |
| `fa-flag-cv` | FLAG | cape,verde |
| `fa-flag-cw` | FLAG | curacao |
| `fa-flag-cx` | FLAG | christmas,island |
| `fa-flag-cy` | FLAG | cyprus |
| `fa-flag-cz` | FLAG | czech,republic |
| `fa-flag-de` | FLAG | germany |
| `fa-flag-dj` | FLAG | djibouti |
| `fa-flag-dk` | FLAG | denmark |
| `fa-flag-dm` | FLAG | dominica |
| `fa-flag-do` | FLAG | dominican,republic |
| `fa-flag-dz` | FLAG | algeria |
| `fa-flag-ec` | FLAG | ecuador |
| `fa-flag-ee` | FLAG | estonia |
| `fa-flag-eg` | FLAG | egypt |
| `fa-flag-eh` | FLAG | western,sahara |
| `fa-flag-er` | FLAG | eritrea |
| `fa-flag-es` | FLAG | spain |
| `fa-flag-et` | FLAG | ethiopia |
| `fa-flag-eu` | FLAG | european,union |
| `fa-flag-fi` | FLAG | finland |
| `fa-flag-fj` | FLAG | fiji |
| `fa-flag-fk` | FLAG | falkland,islands |
| `fa-flag-fm` | FLAG | federated,state,micronesia |
| `fa-flag-fo` | FLAG | faroe,islands |
| `fa-flag-fr` | FLAG | france |
| `fa-flag-ga` | FLAG | gabon |
| `fa-flag-gb` | FLAG | united,kingdom,uk,england |
| `fa-flag-gd` | FLAG | grenada |
| `fa-flag-ge` | FLAG | georgia |
| `fa-flag-gf` | FLAG | french,guiana |
| `fa-flag-gg` | FLAG | guernsey |
| `fa-flag-gh` | FLAG | ghana |
| `fa-flag-gi` | FLAG | gibraltar |
| `fa-flag-gl` | FLAG | greenland |
| `fa-flag-gm` | FLAG | gambia |
| `fa-flag-gn` | FLAG | guinea |
| `fa-flag-gp` | FLAG | guadeloupe |
| `fa-flag-gq` | FLAG | equatorial,guinea |
| `fa-flag-gr` | FLAG | greece |
| `fa-flag-gs` | FLAG | georgia,south,sandwich,islands |
| `fa-flag-gt` | FLAG | guatemala |
| `fa-flag-gu` | FLAG | guam |
| `fa-flag-gw` | FLAG | guinea,bissau |
| `fa-flag-gy` | FLAG | guyana |
| `fa-flag-hk` | FLAG | hong,kong |
| `fa-flag-hm` | FLAG | heard,islands,mcdonald |
| `fa-flag-hn` | FLAG | honduras |
| `fa-flag-hr` | FLAG | croatia |
| `fa-flag-ht` | FLAG | haiti |
| `fa-flag-hu` | FLAG | hungary |
| `fa-flag-ic` | FLAG | canary,islands |
| `fa-flag-id` | FLAG | indonesia |
| `fa-flag-ie` | FLAG | ireland |
| `fa-flag-il` | FLAG | israel |
| `fa-flag-im` | FLAG | man,isle |
| `fa-flag-in` | FLAG | india |
| `fa-flag-io` | FLAG | british,indian,ocean,territory |
| `fa-flag-iq` | FLAG | iraq |
| `fa-flag-ir` | FLAG | iran |
| `fa-flag-is` | FLAG | iceland |
| `fa-flag-it` | FLAG | italy |
| `fa-flag-je` | FLAG | jersey |
| `fa-flag-jm` | FLAG | jamaica |
| `fa-flag-jo` | FLAG | jordan |
| `fa-flag-jp` | FLAG | japan |
| `fa-flag-ke` | FLAG | kenya |
| `fa-flag-kg` | FLAG | kyrgyzstan |
| `fa-flag-kh` | FLAG | cambodia |
| `fa-flag-ki` | FLAG | kiribati |
| `fa-flag-km` | FLAG | comoros |
| `fa-flag-kn` | FLAG | saint,kitts,nevis |
| `fa-flag-kp` | FLAG | north,korea |
| `fa-flag-kr` | FLAG | south,korea |
| `fa-flag-kw` | FLAG | kuwait |
| `fa-flag-ky` | FLAG | cayman,islands |
| `fa-flag-kz` | FLAG | kazakhstan |
| `fa-flag-la` | FLAG | laos |
| `fa-flag-lb` | FLAG | lebanon |
| `fa-flag-lc` | FLAG | saint,lucia |
| `fa-flag-li` | FLAG | liechtenstein |
| `fa-flag-lk` | FLAG | sri,lanka |
| `fa-flag-lr` | FLAG | liberia |
| `fa-flag-ls` | FLAG | lesotho |
| `fa-flag-lt` | FLAG | lithuania |
| `fa-flag-lu` | FLAG | luxemborg |
| `fa-flag-lv` | FLAG | latvia |
| `fa-flag-ly` | FLAG | libya |
| `fa-flag-ma` | FLAG | morocco |
| `fa-flag-mc` | FLAG | monaco |
| `fa-flag-md` | FLAG | moldova |
| `fa-flag-me` | FLAG | montenegro |
| `fa-flag-mf` | FLAG | saint,martin |
| `fa-flag-mg` | FLAG | madagascar |
| `fa-flag-mh` | FLAG | marshall,islands |
| `fa-flag-mk` | FLAG | north,macedonia |
| `fa-flag-ml` | FLAG | mali |
| `fa-flag-mm` | FLAG | myanmar |
| `fa-flag-mn` | FLAG | mongolia |
| `fa-flag-mo` | FLAG | macau |
| `fa-flag-mp` | FLAG | northern,mariana,islands |
| `fa-flag-mq` | FLAG | martinique |
| `fa-flag-mr` | FLAG | mauritania |
| `fa-flag-ms` | FLAG | montserrat |
| `fa-flag-mt` | FLAG | malta |
| `fa-flag-mu` | FLAG | mauritius |
| `fa-flag-mv` | FLAG | maldives |
| `fa-flag-mw` | FLAG | malawi |
| `fa-flag-mx` | FLAG | mexico |
| `fa-flag-my` | FLAG | malaysia |
| `fa-flag-mz` | FLAG | mozambique |
| `fa-flag-na` | FLAG | namibia |
| `fa-flag-nc` | FLAG | caledonia,new |
| `fa-flag-ne` | FLAG | niger |
| `fa-flag-nf` | FLAG | norfolk,island |
| `fa-flag-ng` | FLAG | nigeria |
| `fa-flag-ni` | FLAG | nicaragua |
| `fa-flag-nl` | FLAG | netherlands |
| `fa-flag-no` | FLAG | norway |
| `fa-flag-np` | FLAG | nepal |
| `fa-flag-nr` | FLAG | nauru |
| `fa-flag-nu` | FLAG | niue |
| `fa-flag-nz` | FLAG | zealand,new |
| `fa-flag-o` | WEB_APPLICATION | report,notification |
| `fa-flag-om` | FLAG | oman |
| `fa-flag-pa` | FLAG | panama |
| `fa-flag-pe` | FLAG | peru |
| `fa-flag-pennant` | WEB_APPLICATION | map,marker,pin,navigation,location,way finding |
| `fa-flag-pennant-o` | WEB_APPLICATION | map,marker,pin,navigation,location,way finding |
| `fa-flag-pf` | FLAG | polynesia,french |
| `fa-flag-pg` | FLAG | papaue,guinea,new |
| `fa-flag-ph` | FLAG | philippines |
| `fa-flag-pk` | FLAG | pakistan |
| `fa-flag-pl` | FLAG | poland |
| `fa-flag-pm` | FLAG | saint,pierre,miquelon |
| `fa-flag-pn` | FLAG | pitcairn,islands |
| `fa-flag-pr` | FLAG | puerto,rico |
| `fa-flag-ps` | FLAG | palestine |
| `fa-flag-pt` | FLAG | portugal |
| `fa-flag-pw` | FLAG | palau |
| `fa-flag-py` | FLAG | paraguay |
| `fa-flag-qa` | FLAG | qatar |
| `fa-flag-re` | FLAG | reunion |
| `fa-flag-ro` | FLAG | romania |
| `fa-flag-rs` | FLAG | serbia |
| `fa-flag-ru` | FLAG | russia |
| `fa-flag-rw` | FLAG | rwanda |
| `fa-flag-sa` | FLAG | saudi,arabia |
| `fa-flag-sb` | FLAG | solomon,islands |
| `fa-flag-sc` | FLAG | seychelles |
| `fa-flag-sd` | FLAG | sudan |
| `fa-flag-se` | FLAG | sweden |
| `fa-flag-sg` | FLAG | singapore |
| `fa-flag-sh` | FLAG | helena,saint |
| `fa-flag-si` | FLAG | slovenia |
| `fa-flag-sj` | FLAG | svalbard,janmayen |
| `fa-flag-sk` | FLAG | slovakia |
| `fa-flag-sl` | FLAG | sierra,leone |
| `fa-flag-sm` | FLAG | sanmarino |
| `fa-flag-sn` | FLAG | senegal |
| `fa-flag-so` | FLAG | somalia |
| `fa-flag-sr` | FLAG | suriname |
| `fa-flag-ss` | FLAG | south,sudan |
| `fa-flag-st` | FLAG | saotome,principe |
| `fa-flag-sv` | FLAG | elsalvador |
| `fa-flag-swallowtail` | WEB_APPLICATION | map,marker,pin,navigation,location,way finding |
| `fa-flag-swallowtail-o` | WEB_APPLICATION | map,marker,pin,navigation,location,way finding |
| `fa-flag-sx` | FLAG | sint,maarten |
| `fa-flag-sy` | FLAG | syria |
| `fa-flag-sz` | FLAG | eswatini |
| `fa-flag-tc` | FLAG | turks,caicos,islands |
| `fa-flag-td` | FLAG | chad |
| `fa-flag-tf` | FLAG | french,antarctic |
| `fa-flag-tg` | FLAG | togo |
| `fa-flag-th` | FLAG | thailand |
| `fa-flag-tj` | FLAG | tajikistan |
| `fa-flag-tk` | FLAG | tokelau |
| `fa-flag-tl` | FLAG | timorleste |
| `fa-flag-tm` | FLAG | turkmenistan |
| `fa-flag-tn` | FLAG | tunisia |
| `fa-flag-to` | FLAG | tonga |
| `fa-flag-tr` | FLAG | turkey |
| `fa-flag-tt` | FLAG | trinidad,tobago |
| `fa-flag-tv` | FLAG | tuvalu |
| `fa-flag-tw` | FLAG | taiwan |
| `fa-flag-tz` | FLAG | tanzania |
| `fa-flag-ua` | FLAG | ukraine |
| `fa-flag-ug` | FLAG | uganda |
| `fa-flag-um` | FLAG | us,minor,islands,outlying |
| `fa-flag-us` | FLAG | united,states,usa |
| `fa-flag-us-vi` | FLAG | us,virgin,islands,usvirginislands |
| `fa-flag-uy` | FLAG | uruguay |
| `fa-flag-uz` | FLAG | uzbekistan |
| `fa-flag-va` | FLAG | vaticancity |
| `fa-flag-vc` | FLAG | saint,vincent,grenadines |
| `fa-flag-ve` | FLAG | venezuela |
| `fa-flag-vg` | FLAG | britishvirginislands,british,virgin,islands |
| `fa-flag-vi` | FLAG | us,virgin,islands,usvirginislands |
| `fa-flag-vn` | FLAG | vietnam |
| `fa-flag-vu` | FLAG | vanuatu |
| `fa-flag-wf` | FLAG | wallis,futuna |
| `fa-flag-ws` | FLAG | samoa |
| `fa-flag-xk` | FLAG | kosovo |
| `fa-flag-ye` | FLAG | yemen |
| `fa-flag-yt` | FLAG | mayotte |
| `fa-flag-za` | FLAG | southafrica,south,africa |
| `fa-flag-zm` | FLAG | zambia |
| `fa-flag-zw` | FLAG | zimbabwe |
| `fa-flashlight` | WEB_APPLICATION | find,search |
| `fa-flask` | WEB_APPLICATION | science,beaker,experimental,labs |
| `fa-folder` | WEB_APPLICATION |  |
| `fa-folder-arrow-down` | WEB_APPLICATION |  |
| `fa-folder-arrow-up` | WEB_APPLICATION |  |
| `fa-folder-ban` | WEB_APPLICATION |  |
| `fa-folder-bookmark` | WEB_APPLICATION |  |
| `fa-folder-chart` | WEB_APPLICATION |  |
| `fa-folder-check` | WEB_APPLICATION |  |
| `fa-folder-clock` | WEB_APPLICATION | history |
| `fa-folder-cloud` | WEB_APPLICATION |  |
| `fa-folder-cursor` | WEB_APPLICATION |  |
| `fa-folder-edit` | WEB_APPLICATION | pencil |
| `fa-folder-file` | WEB_APPLICATION |  |
| `fa-folder-heart` | WEB_APPLICATION | like,favorite |
| `fa-folder-lock` | WEB_APPLICATION |  |
| `fa-folder-network` | WEB_APPLICATION |  |
| `fa-folder-new` | WEB_APPLICATION |  |
| `fa-folder-o` | WEB_APPLICATION |  |
| `fa-folder-open` | WEB_APPLICATION |  |
| `fa-folder-open-o` | WEB_APPLICATION |  |
| `fa-folder-play` | WEB_APPLICATION |  |
| `fa-folder-plus` | WEB_APPLICATION |  |
| `fa-folder-pointer` | WEB_APPLICATION |  |
| `fa-folder-search` | WEB_APPLICATION |  |
| `fa-folder-user` | WEB_APPLICATION |  |
| `fa-folder-wrench` | WEB_APPLICATION |  |
| `fa-folder-x` | WEB_APPLICATION | delete,remove |
| `fa-folders` | WEB_APPLICATION |  |
| `fa-font` | TEXT_EDITOR | text |
| `fa-font-size` | WEB_APPLICATION | text |
| `fa-font-size-decrease` | WEB_APPLICATION | text |
| `fa-font-size-increase` | WEB_APPLICATION | text |
| `fa-format` | WEB_APPLICATION | indentation,code |
| `fa-forms` | WEB_APPLICATION | input |
| `fa-forward` | VIDEO_PLAYER | forward,next |
| `fa-frown` | WEB_APPLICATION | emotion,face,emoji,sad |
| `fa-frown-o` | WEB_APPLICATION | emoticon,sad,disapprove,rating |
| `fa-function` | WEB_APPLICATION | computation,procedure,fx |
| `fa-funnel-chart` | CHART |  |
| `fa-futbol-o` | WEB_APPLICATION | soccer |
| `fa-gamepad` | WEB_APPLICATION | controller |
| `fa-gantt-chart` | CHART |  |
| `fa-gavel` | WEB_APPLICATION | legal |
| `fa-gbp` | CURRENCY |  |
| `fa-gear` | WEB_APPLICATION:SPINNER | settings,cog |
| `fa-gears` | WEB_APPLICATION | cogs,settings |
| `fa-genderless` | GENDER |  |
| `fa-gift` | WEB_APPLICATION | present |
| `fa-glass` | WEB_APPLICATION | martini,drink,bar,alcohol,liquor |
| `fa-glasses` | WEB_APPLICATION |  |
| `fa-globe` | WEB_APPLICATION | world,planet,map,place,travel,earth,global,translate,all,language,localize,location,coordinates,country |
| `fa-graduation-cap` | WEB_APPLICATION | mortar board,learning,school,student |
| `fa-h-square` | MEDICAL | hospital,hotel |
| `fa-hand-coins` | BUSINESS | payment,money |
| `fa-hand-grab-o` | WEB_APPLICATION:HAND | hand rock |
| `fa-hand-lizard-o` | WEB_APPLICATION:HAND |  |
| `fa-hand-money-bag` | BUSINESS | payment |
| `fa-hand-o-down` | DIRECTIONAL:HAND | point |
| `fa-hand-o-left` | DIRECTIONAL:HAND | point,left,previous,back |
| `fa-hand-o-right` | DIRECTIONAL:HAND | point,right,next,forward |
| `fa-hand-o-up` | DIRECTIONAL:HAND | point |
| `fa-hand-peace-o` | WEB_APPLICATION:HAND |  |
| `fa-hand-pointer-o` | WEB_APPLICATION:HAND |  |
| `fa-hand-scissors-o` | WEB_APPLICATION:HAND |  |
| `fa-hand-spock-o` | WEB_APPLICATION:HAND |  |
| `fa-hand-stop-o` | WEB_APPLICATION:HAND | hand paper |
| `fa-handshake-o` | WEB_APPLICATION | agreement |
| `fa-hard-of-hearing` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-hardware` | WEB_APPLICATION | chip,computer |
| `fa-hashtag` | WEB_APPLICATION |  |
| `fa-hdd-o` | WEB_APPLICATION | harddrive,harddrive,storage,save |
| `fa-head-ai-sparkle` | AI | smart,brain,idea,inspiration |
| `fa-head-microchip` | AI | chip |
| `fa-header` | TEXT_EDITOR | heading |
| `fa-headphones` | WEB_APPLICATION | sound,listen,music |
| `fa-headset` | WEB_APPLICATION | chat,support,help |
| `fa-heart` | WEB_APPLICATION:MEDICAL | love,like,favorite |
| `fa-heart-o` | WEB_APPLICATION:MEDICAL | love,like,favorite |
| `fa-heartbeat` | WEB_APPLICATION:MEDICAL | ekg |
| `fa-heat-map` | WEB_APPLICATION | bubble,spot,circle |
| `fa-helicopter` | WEB_APPLICATION |  |
| `fa-hero` | WEB_APPLICATION |  |
| `fa-hipster` | EMOJI |  |
| `fa-history` | WEB_APPLICATION |  |
| `fa-home` | WEB_APPLICATION | main,house |
| `fa-hospital-o` | MEDICAL | building |
| `fa-hourglass` | WEB_APPLICATION |  |
| `fa-hourglass-1` | WEB_APPLICATION | hourglass-start |
| `fa-hourglass-2` | WEB_APPLICATION | hourglass-half |
| `fa-hourglass-3` | WEB_APPLICATION | hourglass-end |
| `fa-hourglass-o` | WEB_APPLICATION |  |
| `fa-i-cursor` | WEB_APPLICATION |  |
| `fa-id-badge` | WEB_APPLICATION | lanyard |
| `fa-id-card` | WEB_APPLICATION | drivers license, identification, identity |
| `fa-id-card-o` | WEB_APPLICATION | drivers license, identification, identity |
| `fa-ils` | CURRENCY | shekel,sheqel |
| `fa-image` | WEB_APPLICATION | photo,picture |
| `fa-inbox` | WEB_APPLICATION |  |
| `fa-indent` | TEXT_EDITOR |  |
| `fa-index` | WEB_APPLICATION |  |
| `fa-industry` | WEB_APPLICATION |  |
| `fa-info` | WEB_APPLICATION | help,information,more,details |
| `fa-info-circle` | WEB_APPLICATION | help,information,more,details |
| `fa-info-circle-o` | WEB_APPLICATION | help,information,more,details |
| `fa-info-square` | WEB_APPLICATION | help,information,more,details |
| `fa-info-square-o` | WEB_APPLICATION | help,information,more,details |
| `fa-inr` | CURRENCY | rupee |
| `fa-italic` | TEXT_EDITOR | italics |
| `fa-jpy` | CURRENCY | japan,yen |
| `fa-key` | WEB_APPLICATION | unlock,password |
| `fa-key-alt` | WEB_APPLICATION | lock,key |
| `fa-keyboard-o` | WEB_APPLICATION | type,input |
| `fa-krw` | CURRENCY | won |
| `fa-language` | WEB_APPLICATION |  |
| `fa-laptop` | WEB_APPLICATION | demo,computer,device |
| `fa-layers` | WEB_APPLICATION |  |
| `fa-layout-1col-2col` | WEB_APPLICATION |  |
| `fa-layout-1col-3col` | WEB_APPLICATION |  |
| `fa-layout-1row-2row` | WEB_APPLICATION |  |
| `fa-layout-2col` | WEB_APPLICATION |  |
| `fa-layout-2col-1col` | WEB_APPLICATION |  |
| `fa-layout-2row` | WEB_APPLICATION |  |
| `fa-layout-2row-1row` | WEB_APPLICATION |  |
| `fa-layout-3col` | WEB_APPLICATION |  |
| `fa-layout-3col-1col` | WEB_APPLICATION |  |
| `fa-layout-3row` | WEB_APPLICATION |  |
| `fa-layout-blank` | WEB_APPLICATION |  |
| `fa-layout-footer` | WEB_APPLICATION |  |
| `fa-layout-grid-3x` | WEB_APPLICATION |  |
| `fa-layout-header` | WEB_APPLICATION |  |
| `fa-layout-header-1col-3col` | WEB_APPLICATION |  |
| `fa-layout-header-2row` | WEB_APPLICATION |  |
| `fa-layout-header-footer` | WEB_APPLICATION |  |
| `fa-layout-header-nav-left-cards` | WEB_APPLICATION |  |
| `fa-layout-header-nav-left-right-footer` | WEB_APPLICATION |  |
| `fa-layout-header-nav-right-cards` | WEB_APPLICATION |  |
| `fa-layout-header-sidebar-left` | WEB_APPLICATION |  |
| `fa-layout-header-sidebar-right` | WEB_APPLICATION |  |
| `fa-layout-list-left` | WEB_APPLICATION |  |
| `fa-layout-list-right` | WEB_APPLICATION |  |
| `fa-layout-modal-blank` | WEB_APPLICATION |  |
| `fa-layout-modal-columns` | WEB_APPLICATION |  |
| `fa-layout-modal-grid-2x` | WEB_APPLICATION |  |
| `fa-layout-modal-header` | WEB_APPLICATION |  |
| `fa-layout-modal-nav-left` | WEB_APPLICATION |  |
| `fa-layout-modal-nav-right` | WEB_APPLICATION |  |
| `fa-layout-modal-rows` | WEB_APPLICATION |  |
| `fa-layout-nav-left` | WEB_APPLICATION |  |
| `fa-layout-nav-left-cards` | WEB_APPLICATION |  |
| `fa-layout-nav-left-hamburger` | WEB_APPLICATION |  |
| `fa-layout-nav-left-hamburger-header` | WEB_APPLICATION |  |
| `fa-layout-nav-left-header-cards` | WEB_APPLICATION |  |
| `fa-layout-nav-left-header-header` | WEB_APPLICATION |  |
| `fa-layout-nav-left-right` | WEB_APPLICATION |  |
| `fa-layout-nav-left-right-header-footer` | WEB_APPLICATION |  |
| `fa-layout-nav-right` | WEB_APPLICATION |  |
| `fa-layout-nav-right-cards` | WEB_APPLICATION |  |
| `fa-layout-nav-right-hamburger` | WEB_APPLICATION |  |
| `fa-layout-nav-right-hamburger-header` | WEB_APPLICATION |  |
| `fa-layout-nav-right-header` | WEB_APPLICATION |  |
| `fa-layout-nav-right-header-cards` | WEB_APPLICATION |  |
| `fa-layout-sidebar-left` | WEB_APPLICATION |  |
| `fa-layout-sidebar-right` | WEB_APPLICATION |  |
| `fa-layouts-grid-2x` | WEB_APPLICATION |  |
| `fa-leaf` | WEB_APPLICATION | eco,nature |
| `fa-lemon-o` | WEB_APPLICATION |  |
| `fa-level-down` | WEB_APPLICATION |  |
| `fa-level-up` | WEB_APPLICATION |  |
| `fa-life-ring` | WEB_APPLICATION | lifebuoy,lifesaver,support |
| `fa-lightbulb-o` | WEB_APPLICATION | idea,inspiration |
| `fa-line-area-chart` | CHART |  |
| `fa-line-chart` | WEB_APPLICATION:CHART | graph,analytics |
| `fa-line-map` | MAPS | road,train,subway |
| `fa-link` | TEXT_EDITOR | chain |
| `fa-list` | TEXT_EDITOR | ul,ol,checklist,finished,completed,done,todo |
| `fa-list-alt` | TEXT_EDITOR | ul,ol,checklist,finished,completed,done,todo |
| `fa-list-ol` | TEXT_EDITOR | ul,ol,checklist,list,todo,list,numbers |
| `fa-list-ul` | TEXT_EDITOR | ul,ol,checklist,todo,list |
| `fa-location` | MAPS | map,crosshairs |
| `fa-location-arrow` | MAPS | navigation,map,way finding,compass,direction |
| `fa-location-arrow-o` | WEB_APPLICATION | map,coordinates,location,address,place,where |
| `fa-location-circle` | MAPS | navigation,map,way finding,compass,direction |
| `fa-location-circle-o` | MAPS | navigation,map,way finding,compass,direction |
| `fa-location-slash` | MAPS | map,crosshairs |
| `fa-lock` | WEB_APPLICATION | protect,admin |
| `fa-lock-check` | WEB_APPLICATION |  |
| `fa-lock-file` | WEB_APPLICATION |  |
| `fa-lock-new` | WEB_APPLICATION |  |
| `fa-lock-password` | WEB_APPLICATION |  |
| `fa-lock-plus` | WEB_APPLICATION |  |
| `fa-lock-user` | WEB_APPLICATION |  |
| `fa-lock-x` | WEB_APPLICATION | delete,remove |
| `fa-long-arrow-down` | DIRECTIONAL |  |
| `fa-long-arrow-left` | DIRECTIONAL | previous,back |
| `fa-long-arrow-right` | DIRECTIONAL |  |
| `fa-long-arrow-up` | DIRECTIONAL |  |
| `fa-low-vision` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-magic` | WEB_APPLICATION | wizard,automatic,autocomplete |
| `fa-magnet` | WEB_APPLICATION |  |
| `fa-mail-forward` | WEB_APPLICATION | mail share |
| `fa-male` | WEB_APPLICATION | man,user,person,profile |
| `fa-map` | WEB_APPLICATION |  |
| `fa-map-marker` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-marker-camera` | MAPS | pin,navigation,location,way finding,directions,photo,photography |
| `fa-map-marker-camera-o` | MAPS | pin,navigation,location,way finding,directions,photo,photography |
| `fa-map-marker-check` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-marker-check-o` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-marker-face-frown` | MAPS | pin,navigation,location,way finding,directions,emoji,sad |
| `fa-map-marker-face-frown-o` | MAPS | pin,navigation,location,way finding,directions,emoji,sad |
| `fa-map-marker-face-meh` | MAPS | pin,navigation,location,way finding,directions,emoji,neutral |
| `fa-map-marker-face-meh-o` | MAPS | pin,navigation,location,way finding,directions,emoji,neutral |
| `fa-map-marker-face-smile` | MAPS | pin,navigation,location,way finding,directions,emoji,happy |
| `fa-map-marker-face-smile-o` | MAPS | pin,navigation,location,way finding,directions,emoji,happy |
| `fa-map-marker-o` | WEB_APPLICATION | map,pin,location,coordinates,localize,address,travel,where,place |
| `fa-map-marker-shine` | MAPS | pin,navigation,location,way finding,directions,highlight |
| `fa-map-marker-shine-o` | MAPS | pin,navigation,location,way finding,directions,highlight |
| `fa-map-marker-slash` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-marker-slash-o` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-markers` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-markers-o` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-o` | WEB_APPLICATION |  |
| `fa-map-pin` | WEB_APPLICATION |  |
| `fa-map-pin-circle` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-pin-circle-o` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-pin-heart` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-pin-heart-o` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-pin-triangle` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-pin-triangle-o` | MAPS | pin,navigation,location,way finding,directions |
| `fa-map-signs` | WEB_APPLICATION |  |
| `fa-mars` | GENDER | male |
| `fa-mars-double` | GENDER |  |
| `fa-mars-stroke` | GENDER |  |
| `fa-mars-stroke-h` | GENDER |  |
| `fa-mars-stroke-v` | GENDER |  |
| `fa-materialized-view` | WEB_APPLICATION |  |
| `fa-media-list` | WEB_APPLICATION |  |
| `fa-medical-mask` | MEDICAL | safety,protection |
| `fa-medication` | MEDICAL | medicine,drug |
| `fa-medication-pill` | MEDICAL | medicine,drug |
| `fa-medication-pill-bottle` | MEDICAL | medicine,drug |
| `fa-medication-pills` | MEDICAL | medicine,drug |
| `fa-medkit` | MEDICAL | firstaid,firstaid,help,support,health |
| `fa-meeting-room` | BUSINESS |  |
| `fa-meh` | WEB_APPLICATION | emotion,face,emoji,neutral |
| `fa-meh-o` | WEB_APPLICATION | emoticon,rating,neutral |
| `fa-mercury` | GENDER | transgender |
| `fa-microchip` | WEB_APPLICATION | silicon,chip,cpu |
| `fa-microphone` | WEB_APPLICATION | record,voice,sound |
| `fa-microphone-slash` | WEB_APPLICATION | record,voice,sound,mute |
| `fa-military-vehicle` | WEB_APPLICATION | humvee,car,truck |
| `fa-minus` | WEB_APPLICATION | hide,minify,delete,remove,trash,hide,collapse |
| `fa-minus-circle` | WEB_APPLICATION | delete,remove,trash,hide |
| `fa-minus-circle-o` | WEB_APPLICATION | delete,remove,trash,hide |
| `fa-minus-square` | WEB_APPLICATION:FORM_CONTROL | hide,minify,delete,remove,trash,hide,collapse |
| `fa-minus-square-o` | WEB_APPLICATION:FORM_CONTROL | hide,minify,delete,remove,trash,hide,collapse |
| `fa-missile` | WEB_APPLICATION |  |
| `fa-mobile` | WEB_APPLICATION | cellphone,cellphone,text,call,iphone,number,phone |
| `fa-money` | WEB_APPLICATION:CURRENCY | cash,money,buy,checkout,purchase,payment |
| `fa-money-bag` | BUSINESS | payment |
| `fa-money-check-pen` | BUSINESS | payment |
| `fa-money-deposit` | BUSINESS | payment |
| `fa-money-withdrawal` | BUSINESS |  |
| `fa-moon-o` | WEB_APPLICATION | night,darker,contrast |
| `fa-motorcycle` | WEB_APPLICATION:TRANSPORTATION | vehicle,bike |
| `fa-mouse-pointer` | WEB_APPLICATION |  |
| `fa-music` | WEB_APPLICATION | note,sound |
| `fa-navicon` | WEB_APPLICATION | reorder,menu,drag,reorder,settings,list,ul,ol,checklist,todo,list,hamburger |
| `fa-network-hub` | WEB_APPLICATION |  |
| `fa-network-triangle` | WEB_APPLICATION |  |
| `fa-neuter` | GENDER |  |
| `fa-newspaper-o` | WEB_APPLICATION | press |
| `fa-nfc` | BUSINESS | payment,tap |
| `fa-notebook` | WEB_APPLICATION |  |
| `fa-number-0` | NUMBERS |  |
| `fa-number-0-o` | NUMBERS |  |
| `fa-number-1` | NUMBERS |  |
| `fa-number-1-o` | NUMBERS |  |
| `fa-number-2` | NUMBERS |  |
| `fa-number-2-o` | NUMBERS |  |
| `fa-number-3` | NUMBERS |  |
| `fa-number-3-o` | NUMBERS |  |
| `fa-number-4` | NUMBERS |  |
| `fa-number-4-o` | NUMBERS |  |
| `fa-number-5` | NUMBERS |  |
| `fa-number-5-o` | NUMBERS |  |
| `fa-number-6` | NUMBERS |  |
| `fa-number-6-o` | NUMBERS |  |
| `fa-number-7` | NUMBERS |  |
| `fa-number-7-o` | NUMBERS |  |
| `fa-number-8` | NUMBERS |  |
| `fa-number-8-o` | NUMBERS |  |
| `fa-number-9` | NUMBERS |  |
| `fa-number-9-o` | NUMBERS |  |
| `fa-nurse` | MEDICAL | hospital,doctor,paramedic |
| `fa-object-group` | WEB_APPLICATION |  |
| `fa-object-ungroup` | WEB_APPLICATION |  |
| `fa-office-phone` | WEB_APPLICATION | phone,fax |
| `fa-outdent` | TEXT_EDITOR | dedent |
| `fa-package` | WEB_APPLICATION | product |
| `fa-padlock` | WEB_APPLICATION |  |
| `fa-padlock-unlock` | WEB_APPLICATION |  |
| `fa-page-bottom` | DIRECTIONAL |  |
| `fa-page-first` | DIRECTIONAL |  |
| `fa-page-last` | DIRECTIONAL |  |
| `fa-page-top` | DIRECTIONAL |  |
| `fa-paint-brush` | WEB_APPLICATION |  |
| `fa-paper-plane` | WEB_APPLICATION | send |
| `fa-paper-plane-o` | WEB_APPLICATION | sendo |
| `fa-paperclip` | TEXT_EDITOR | attachment |
| `fa-paragraph` | TEXT_EDITOR |  |
| `fa-paste` | TEXT_EDITOR | clipboard |
| `fa-pause` | VIDEO_PLAYER | wait |
| `fa-pause-circle` | VIDEO_PLAYER |  |
| `fa-pause-circle-o` | VIDEO_PLAYER |  |
| `fa-paw` | WEB_APPLICATION | pet |
| `fa-pencil` | WEB_APPLICATION | write,edit,update |
| `fa-pencil-square` | WEB_APPLICATION | write,edit,update |
| `fa-pencil-square-o` | WEB_APPLICATION | write,edit,update,edit |
| `fa-percent` | WEB_APPLICATION |  |
| `fa-person-running` | WEB_APPLICATION | fast |
| `fa-person-running-fast` | WEB_APPLICATION | fast,faster |
| `fa-person-standing` | WEB_APPLICATION | idle |
| `fa-person-walking` | WEB_APPLICATION | slow |
| `fa-phone` | WEB_APPLICATION | call,voice,number,support,earphone |
| `fa-phone-square` | WEB_APPLICATION | call,voice,number,support |
| `fa-photo` | WEB_APPLICATION | image,picture |
| `fa-pie-chart` | WEB_APPLICATION:CHART | graph,analytics |
| `fa-pie-chart-0` | CHART |  |
| `fa-pie-chart-10` | CHART |  |
| `fa-pie-chart-100` | CHART |  |
| `fa-pie-chart-15` | CHART |  |
| `fa-pie-chart-20` | CHART |  |
| `fa-pie-chart-25` | CHART |  |
| `fa-pie-chart-30` | CHART |  |
| `fa-pie-chart-35` | CHART |  |
| `fa-pie-chart-40` | CHART |  |
| `fa-pie-chart-45` | CHART |  |
| `fa-pie-chart-5` | CHART |  |
| `fa-pie-chart-50` | CHART |  |
| `fa-pie-chart-55` | CHART |  |
| `fa-pie-chart-60` | CHART |  |
| `fa-pie-chart-65` | CHART |  |
| `fa-pie-chart-70` | CHART |  |
| `fa-pie-chart-75` | CHART |  |
| `fa-pie-chart-80` | CHART |  |
| `fa-pie-chart-85` | CHART |  |
| `fa-pie-chart-90` | CHART |  |
| `fa-pie-chart-95` | CHART |  |
| `fa-piggy-bank` | BUSINESS | money |
| `fa-plane` | WEB_APPLICATION:TRANSPORTATION | travel,trip,location,destination,airplane,fly,mode |
| `fa-play` | VIDEO_PLAYER | start,playing,music,sound |
| `fa-play-circle` | VIDEO_PLAYER | start,playing |
| `fa-play-circle-o` | VIDEO_PLAYER |  |
| `fa-plug` | WEB_APPLICATION |  |
| `fa-plus` | WEB_APPLICATION | add,new,create,expand |
| `fa-plus-circle` | WEB_APPLICATION | add,new,create,expand |
| `fa-plus-circle-o` | WEB_APPLICATION | add,new,create,expand |
| `fa-plus-square` | MEDICAL:WEB_APPLICATION:FORM_CONTROL | add,new,create,expand |
| `fa-plus-square-o` | WEB_APPLICATION:FORM_CONTROL | add,new,create,expand |
| `fa-podcast` | WEB_APPLICATION |  |
| `fa-podium` | WEB_APPLICATION | presentation,presenter,lecture,lecturer,speaker |
| `fa-polar-chart` | CHART |  |
| `fa-power-off` | WEB_APPLICATION | on |
| `fa-pragma` | WEB_APPLICATION | number,sign,hash,sharp |
| `fa-prescription` | MEDICAL | medicine,drug |
| `fa-prescription-sheet` | MEDICAL | medicine,drug |
| `fa-presentation` | WEB_APPLICATION | chart,presentation,performance |
| `fa-print` | WEB_APPLICATION |  |
| `fa-procedure` | WEB_APPLICATION | computation,function |
| `fa-projector` | BUSINESS |  |
| `fa-projector-screen` | BUSINESS | presentation |
| `fa-puzzle-piece` | WEB_APPLICATION | addon,addon,section |
| `fa-pyramid-chart` | CHART |  |
| `fa-qrcode` | WEB_APPLICATION | scan |
| `fa-question` | WEB_APPLICATION | help,information,unknown,support |
| `fa-question-circle` | WEB_APPLICATION | help,information,unknown,support |
| `fa-question-circle-o` | WEB_APPLICATION | help,information,unknown,support |
| `fa-question-square` | WEB_APPLICATION | help,information,unknown,support |
| `fa-question-square-o` | WEB_APPLICATION | help,information,unknown,support |
| `fa-quote-left` | WEB_APPLICATION |  |
| `fa-quote-right` | WEB_APPLICATION |  |
| `fa-radar-chart` | CHART |  |
| `fa-radiation` | MEDICAL | danger,x ray,nuclear |
| `fa-random` | WEB_APPLICATION:VIDEO_PLAYER | sort,shuffle |
| `fa-range-chart-area` | CHART |  |
| `fa-range-chart-bar` | CHART |  |
| `fa-receipt` | BUSINESS |  |
| `fa-receipt-x` | BUSINESS |  |
| `fa-recycle` | WEB_APPLICATION |  |
| `fa-redo-alt` | WEB_APPLICATION |  |
| `fa-redo-arrow` | WEB_APPLICATION |  |
| `fa-refresh` | WEB_APPLICATION:SPINNER | reload,sync |
| `fa-registered` | WEB_APPLICATION |  |
| `fa-remove` | WEB_APPLICATION | remove,close,close,exit,x,cross |
| `fa-repeat` | TEXT_EDITOR | redo,forward,rotate |
| `fa-reply` | WEB_APPLICATION | mail |
| `fa-reply-all` | WEB_APPLICATION | mail |
| `fa-retweet` | WEB_APPLICATION | refresh,reload,share |
| `fa-rmb` | CURRENCY | china,renminbi,yuan |
| `fa-road` | WEB_APPLICATION | street |
| `fa-robot` | AI |  |
| `fa-robot-arm` | AI |  |
| `fa-rocket` | WEB_APPLICATION:TRANSPORTATION | app |
| `fa-rotate-left` | TEXT_EDITOR | back,undo |
| `fa-rotate-right` | TEXT_EDITOR | redo,forward,repeat |
| `fa-rss` | WEB_APPLICATION | blog,feed |
| `fa-rss-square` | WEB_APPLICATION | feed,blog |
| `fa-rub` | CURRENCY | ruble,rouble |
| `fa-save` | TEXT_EDITOR | floppy |
| `fa-save-as` | WEB_APPLICATION |  |
| `fa-scatter-chart` | CHART |  |
| `fa-scissors` | TEXT_EDITOR | cut |
| `fa-search` | WEB_APPLICATION | magnify,zoom,enlarge,bigger |
| `fa-search-minus` | WEB_APPLICATION | magnify,minify,zoom,smaller |
| `fa-search-plus` | WEB_APPLICATION | magnify,zoom,enlarge,bigger |
| `fa-send` | WEB_APPLICATION | plane |
| `fa-send-o` | WEB_APPLICATION | plane |
| `fa-sequence` | WEB_APPLICATION |  |
| `fa-server` | WEB_APPLICATION |  |
| `fa-server-arrow-down` | WEB_APPLICATION |  |
| `fa-server-arrow-up` | WEB_APPLICATION |  |
| `fa-server-ban` | WEB_APPLICATION |  |
| `fa-server-bookmark` | WEB_APPLICATION |  |
| `fa-server-chart` | WEB_APPLICATION |  |
| `fa-server-check` | WEB_APPLICATION |  |
| `fa-server-clock` | WEB_APPLICATION | history |
| `fa-server-edit` | WEB_APPLICATION |  |
| `fa-server-file` | WEB_APPLICATION |  |
| `fa-server-heart` | WEB_APPLICATION |  |
| `fa-server-lock` | WEB_APPLICATION |  |
| `fa-server-new` | WEB_APPLICATION |  |
| `fa-server-play` | WEB_APPLICATION |  |
| `fa-server-plus` | WEB_APPLICATION |  |
| `fa-server-pointer` | WEB_APPLICATION |  |
| `fa-server-search` | WEB_APPLICATION |  |
| `fa-server-user` | WEB_APPLICATION |  |
| `fa-server-wrench` | WEB_APPLICATION |  |
| `fa-server-x` | WEB_APPLICATION | delete,remove |
| `fa-shapes` | WEB_APPLICATION | shared,components |
| `fa-share` | WEB_APPLICATION | mail forward |
| `fa-share-alt` | WEB_APPLICATION |  |
| `fa-share-alt-square` | WEB_APPLICATION |  |
| `fa-share-square` | WEB_APPLICATION | social,send |
| `fa-share-square-o` | WEB_APPLICATION | social,send |
| `fa-share2` | WEB_APPLICATION |  |
| `fa-shield` | WEB_APPLICATION | award,achievement,winner |
| `fa-ship` | WEB_APPLICATION:TRANSPORTATION | boat,sea |
| `fa-shopping-bag` | WEB_APPLICATION |  |
| `fa-shopping-basket` | WEB_APPLICATION |  |
| `fa-shopping-cart` | WEB_APPLICATION | checkout,buy,purchase,payment |
| `fa-shower` | WEB_APPLICATION |  |
| `fa-sign-in` | WEB_APPLICATION | enter,join,login,login,signup,signin,signin,signup,arrow |
| `fa-sign-language` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-sign-out` | WEB_APPLICATION | logout,logout,leave,exit,arrow |
| `fa-signal` | WEB_APPLICATION |  |
| `fa-signature` | BUSINESS |  |
| `fa-signing` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-sitemap` | WEB_APPLICATION | directory,hierarchy,organization |
| `fa-sitemap-horizontal` | WEB_APPLICATION |  |
| `fa-sitemap-vertical` | WEB_APPLICATION |  |
| `fa-size-l` | WEB_APPLICATION | measurement,shirt,badge |
| `fa-size-m` | WEB_APPLICATION | measurement,shirt,badge |
| `fa-size-s` | WEB_APPLICATION | measurement,shirt,badge |
| `fa-size-xl` | WEB_APPLICATION | measurement,shirt,badge |
| `fa-size-xs` | WEB_APPLICATION | measurement,shirt,badge |
| `fa-size-xxl` | WEB_APPLICATION | measurement,shirt,badge |
| `fa-sliders` | WEB_APPLICATION |  |
| `fa-smile` | WEB_APPLICATION | emotion,face,emoji,happy |
| `fa-smile-o` | WEB_APPLICATION | emoticon,happy,approve,satisfied,rating |
| `fa-snowflake` | WEB_APPLICATION | frozen |
| `fa-soccer-ball-o` | WEB_APPLICATION | football |
| `fa-sort` | WEB_APPLICATION | order,unsorted |
| `fa-sort-alpha-asc` | WEB_APPLICATION |  |
| `fa-sort-alpha-desc` | WEB_APPLICATION |  |
| `fa-sort-amount-asc` | WEB_APPLICATION |  |
| `fa-sort-amount-asc-alt` | WEB_APPLICATION |  |
| `fa-sort-amount-desc` | WEB_APPLICATION |  |
| `fa-sort-amount-desc-alt` | WEB_APPLICATION |  |
| `fa-sort-asc` | WEB_APPLICATION | up |
| `fa-sort-desc` | WEB_APPLICATION | dropdown,more,menu,down |
| `fa-sort-numeric-asc` | WEB_APPLICATION | numbers |
| `fa-sort-numeric-desc` | WEB_APPLICATION | numbers |
| `fa-space-shuttle` | WEB_APPLICATION:TRANSPORTATION |  |
| `fa-sparkles` | AI |  |
| `fa-spinner` | WEB_APPLICATION:SPINNER | loading,progress |
| `fa-spoon` | WEB_APPLICATION |  |
| `fa-square` | WEB_APPLICATION:FORM_CONTROL | block,box |
| `fa-square-o` | WEB_APPLICATION:FORM_CONTROL | block,square,box |
| `fa-square-selected-o` | WEB_APPLICATION:FORM_CONTROL | block,square,box |
| `fa-star` | WEB_APPLICATION | award,achievement,night,rating,score |
| `fa-star-half` | WEB_APPLICATION | award,achievement,rating,score |
| `fa-star-half-o` | WEB_APPLICATION | award,achievement,rating,score,half |
| `fa-star-o` | WEB_APPLICATION | award,achievement,night,rating,score |
| `fa-step-backward` | VIDEO_PLAYER | rewind,previous,beginning,start,first |
| `fa-step-forward` | VIDEO_PLAYER | next,end,last |
| `fa-stethoscope` | MEDICAL |  |
| `fa-sticky-note` | WEB_APPLICATION |  |
| `fa-sticky-note-o` | WEB_APPLICATION |  |
| `fa-stock-chart` | CHART |  |
| `fa-stop` | VIDEO_PLAYER | block,box,square |
| `fa-stop-circle` | VIDEO_PLAYER |  |
| `fa-stop-circle-o` | VIDEO_PLAYER |  |
| `fa-store` | BUSINESS | building |
| `fa-strategy` | BUSINESS |  |
| `fa-street-view` | WEB_APPLICATION | map |
| `fa-strikethrough` | TEXT_EDITOR |  |
| `fa-subscript` | TEXT_EDITOR |  |
| `fa-subway` | TRANSPORTATION |  |
| `fa-suitcase` | WEB_APPLICATION | trip,luggage,travel,move,baggage |
| `fa-sun-o` | WEB_APPLICATION | weather,contrast,lighter,brighten,day |
| `fa-superscript` | TEXT_EDITOR | exponential |
| `fa-support` | WEB_APPLICATION | lifebuoy,lifesaver,lifering |
| `fa-synonym` | WEB_APPLICATION | copy,duplicate |
| `fa-syringe` | MEDICAL | medicine,drug,shot,vaccine,needle |
| `fa-table` | TEXT_EDITOR | data,excel,spreadsheet |
| `fa-table-arrow-down` | WEB_APPLICATION |  |
| `fa-table-arrow-up` | WEB_APPLICATION |  |
| `fa-table-ban` | WEB_APPLICATION |  |
| `fa-table-bookmark` | WEB_APPLICATION |  |
| `fa-table-chart` | WEB_APPLICATION |  |
| `fa-table-check` | WEB_APPLICATION |  |
| `fa-table-clock` | WEB_APPLICATION | history |
| `fa-table-cursor` | WEB_APPLICATION |  |
| `fa-table-edit` | WEB_APPLICATION | pencil |
| `fa-table-file` | WEB_APPLICATION |  |
| `fa-table-heart` | WEB_APPLICATION | like,favorite |
| `fa-table-lock` | WEB_APPLICATION |  |
| `fa-table-new` | WEB_APPLICATION |  |
| `fa-table-play` | WEB_APPLICATION |  |
| `fa-table-plus` | WEB_APPLICATION |  |
| `fa-table-pointer` | WEB_APPLICATION |  |
| `fa-table-search` | WEB_APPLICATION |  |
| `fa-table-user` | WEB_APPLICATION |  |
| `fa-table-wrench` | WEB_APPLICATION |  |
| `fa-table-x` | WEB_APPLICATION | delete,remove |
| `fa-tablet` | WEB_APPLICATION | ipad,device |
| `fa-tabs` | WEB_APPLICATION |  |
| `fa-tachometer` | WEB_APPLICATION | dashboard |
| `fa-tag` | WEB_APPLICATION | label |
| `fa-tags` | WEB_APPLICATION | labels |
| `fa-tank` | WEB_APPLICATION |  |
| `fa-target-arrow` | BUSINESS | bullseye |
| `fa-tasks` | WEB_APPLICATION | progress,loading,downloading,downloads,settings |
| `fa-tasks-alt` | WEB_APPLICATION | check,list,survey |
| `fa-taxi` | WEB_APPLICATION:TRANSPORTATION | cab,vehicle |
| `fa-television` | WEB_APPLICATION | tv |
| `fa-terminal` | WEB_APPLICATION | command,prompt,code |
| `fa-text-color` | WEB_APPLICATION | text,editor,font,format,color |
| `fa-text-height` | TEXT_EDITOR |  |
| `fa-text-width` | TEXT_EDITOR |  |
| `fa-th` | TEXT_EDITOR | blocks,squares,boxes,grid |
| `fa-th-large` | TEXT_EDITOR | blocks,squares,boxes,grid |
| `fa-th-list` | TEXT_EDITOR | ul,ol,checklist,finished,completed,done,todo |
| `fa-thermometer-0` | WEB_APPLICATION | thermometer-empty |
| `fa-thermometer-1` | WEB_APPLICATION | thermometer-quarter |
| `fa-thermometer-2` | WEB_APPLICATION | thermometer-half |
| `fa-thermometer-3` | WEB_APPLICATION | thermometer-three-quarters |
| `fa-thermometer-4` | WEB_APPLICATION | thermometer-full,thermometer |
| `fa-thumb-tack` | WEB_APPLICATION | marker,pin,location,coordinates |
| `fa-thumbs-down` | WEB_APPLICATION:HAND | dislike,disapprove,disagree,hand |
| `fa-thumbs-o-down` | WEB_APPLICATION:HAND | dislike,disapprove,disagree,hand |
| `fa-thumbs-o-up` | WEB_APPLICATION:HAND | like,approve,favorite,agree,hand |
| `fa-thumbs-up` | WEB_APPLICATION:HAND | like,favorite,approve,agree,hand |
| `fa-ticket` | WEB_APPLICATION | movie,pass,support |
| `fa-tiles-2x2` | WEB_APPLICATION |  |
| `fa-tiles-3x3` | WEB_APPLICATION |  |
| `fa-tiles-8` | WEB_APPLICATION |  |
| `fa-tiles-9` | WEB_APPLICATION |  |
| `fa-timeline` | BUSINESS |  |
| `fa-timeline-arrow` | BUSINESS |  |
| `fa-times` | WEB_APPLICATION | remove,close,close,exit,x,cross |
| `fa-times-circle` | WEB_APPLICATION | close,exit,x |
| `fa-times-circle-o` | WEB_APPLICATION | close,exit,x |
| `fa-times-rectangle` | WEB_APPLICATION | remove,close,close,exit,x,cross |
| `fa-times-rectangle-o` | WEB_APPLICATION | remove,close,close,exit,x,cross |
| `fa-times-square` | FORM_CONTROL | remove,close,close,exit,x,cross |
| `fa-times-square-o` | FORM_CONTROL | remove,close,close,exit,x,cross |
| `fa-tint` | WEB_APPLICATION | raindrop,waterdrop,drop,droplet |
| `fa-toggle-off` | WEB_APPLICATION |  |
| `fa-toggle-on` | WEB_APPLICATION |  |
| `fa-tools` | WEB_APPLICATION | screwdriver,wrench |
| `fa-trademark` | WEB_APPLICATION |  |
| `fa-traffic-light` | MAPS | stop,go,sign |
| `fa-traffic-light-go` | MAPS | stop,go,sign |
| `fa-traffic-light-stop` | MAPS | stop,go,sign |
| `fa-train` | TRANSPORTATION |  |
| `fa-transgender` | GENDER | intersex |
| `fa-transgender-alt` | GENDER |  |
| `fa-trash` | WEB_APPLICATION | garbage,delete,remove,hide |
| `fa-trash-o` | WEB_APPLICATION | garbage,delete,remove,trash,hide |
| `fa-tree` | WEB_APPLICATION |  |
| `fa-tree-org` | WEB_APPLICATION |  |
| `fa-trend-down` | BUSINESS | forecast |
| `fa-trend-up` | BUSINESS | forecast |
| `fa-trigger` | WEB_APPLICATION |  |
| `fa-trophy` | WEB_APPLICATION | award,achievement,winner,game |
| `fa-truck` | WEB_APPLICATION:TRANSPORTATION | shipping |
| `fa-try` | CURRENCY | turkey, lira, turkish |
| `fa-tty` | WEB_APPLICATION |  |
| `fa-umbrella` | WEB_APPLICATION |  |
| `fa-underline` | TEXT_EDITOR |  |
| `fa-undo` | TEXT_EDITOR | back,rotate |
| `fa-undo-alt` | WEB_APPLICATION |  |
| `fa-undo-arrow` | WEB_APPLICATION |  |
| `fa-universal-access` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-university` | WEB_APPLICATION | institution,bank |
| `fa-unlink` | TEXT_EDITOR | remove,chain,broken |
| `fa-unlock` | WEB_APPLICATION | protect,admin,password,lock |
| `fa-unlock-alt` | WEB_APPLICATION | protect,admin,password,lock |
| `fa-upload` | WEB_APPLICATION | import |
| `fa-upload-alt` | WEB_APPLICATION |  |
| `fa-usd` | CURRENCY | dollar |
| `fa-user` | WEB_APPLICATION | person,man,head,profile |
| `fa-user-arrow-down` | WEB_APPLICATION |  |
| `fa-user-arrow-up` | WEB_APPLICATION |  |
| `fa-user-ban` | WEB_APPLICATION |  |
| `fa-user-chart` | WEB_APPLICATION |  |
| `fa-user-check` | WEB_APPLICATION |  |
| `fa-user-circle` | WEB_APPLICATION |  |
| `fa-user-circle-o` | WEB_APPLICATION |  |
| `fa-user-clock` | WEB_APPLICATION | history |
| `fa-user-cursor` | WEB_APPLICATION |  |
| `fa-user-edit` | WEB_APPLICATION | pencil |
| `fa-user-graduate` | WEB_APPLICATION |  |
| `fa-user-headset` | WEB_APPLICATION |  |
| `fa-user-heart` | WEB_APPLICATION | like,favorite,love |
| `fa-user-lock` | WEB_APPLICATION |  |
| `fa-user-magnifying-glass` | WEB_APPLICATION |  |
| `fa-user-man` | WEB_APPLICATION |  |
| `fa-user-md` | MEDICAL | doctor,profile,medical,nurse |
| `fa-user-play` | WEB_APPLICATION |  |
| `fa-user-plus` | WEB_APPLICATION | signup,signup |
| `fa-user-pointer` | WEB_APPLICATION |  |
| `fa-user-secret` | WEB_APPLICATION | whisper,spy,incognito |
| `fa-user-slash` | WEB_APPLICATION | person |
| `fa-user-woman` | WEB_APPLICATION |  |
| `fa-user-wrench` | WEB_APPLICATION |  |
| `fa-user-x` | WEB_APPLICATION |  |
| `fa-users` | WEB_APPLICATION | people,profiles,persons,group |
| `fa-users-alt` | WEB_APPLICATION | person |
| `fa-users-chat` | WEB_APPLICATION |  |
| `fa-variable` | WEB_APPLICATION |  |
| `fa-vault` | BUSINESS | money,safe |
| `fa-venus` | GENDER | female |
| `fa-venus-double` | GENDER |  |
| `fa-venus-mars` | GENDER |  |
| `fa-vial` | MEDICAL | medicine,drug,formula,science,test tube,chemistry |
| `fa-vials` | MEDICAL | medicine,drug,formula,science,test tube,chemistry |
| `fa-video-camera` | WEB_APPLICATION | film,movie,record |
| `fa-volume-control-phone` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-volume-down` | WEB_APPLICATION | lower,quieter,sound,music |
| `fa-volume-off` | WEB_APPLICATION | mute,sound,music |
| `fa-volume-up` | WEB_APPLICATION | higher,louder,sound,music |
| `fa-wallet` | BUSINESS | payment |
| `fa-warning` | WEB_APPLICATION | warning,error,problem,notification,alert,warning |
| `fa-wheelchair` | WEB_APPLICATION:MEDICAL:TRANSPORTATION | handicap,person,accessibility,accessible |
| `fa-wheelchair-alt` | WEB_APPLICATION:ACCESSIBILITY |  |
| `fa-wifi` | WEB_APPLICATION |  |
| `fa-window` | WEB_APPLICATION |  |
| `fa-window-alt` | WEB_APPLICATION |  |
| `fa-window-alt-2` | WEB_APPLICATION |  |
| `fa-window-arrow-down` | WEB_APPLICATION |  |
| `fa-window-arrow-up` | WEB_APPLICATION |  |
| `fa-window-ban` | WEB_APPLICATION |  |
| `fa-window-bookmark` | WEB_APPLICATION |  |
| `fa-window-chart` | WEB_APPLICATION |  |
| `fa-window-check` | WEB_APPLICATION |  |
| `fa-window-clock` | WEB_APPLICATION | history |
| `fa-window-close` | WEB_APPLICATION | times, rectangle |
| `fa-window-close-o` | WEB_APPLICATION | times, rectangle |
| `fa-window-cursor` | WEB_APPLICATION |  |
| `fa-window-edit` | WEB_APPLICATION | pencil |
| `fa-window-file` | WEB_APPLICATION |  |
| `fa-window-heart` | WEB_APPLICATION | like,favorite |
| `fa-window-lock` | WEB_APPLICATION |  |
| `fa-window-maximize` | WEB_APPLICATION |  |
| `fa-window-minimize` | WEB_APPLICATION |  |
| `fa-window-new` | WEB_APPLICATION |  |
| `fa-window-play` | WEB_APPLICATION |  |
| `fa-window-plus` | WEB_APPLICATION |  |
| `fa-window-pointer` | WEB_APPLICATION |  |
| `fa-window-restore` | WEB_APPLICATION |  |
| `fa-window-search` | WEB_APPLICATION |  |
| `fa-window-terminal` | WEB_APPLICATION | console |
| `fa-window-user` | WEB_APPLICATION |  |
| `fa-window-wrench` | WEB_APPLICATION |  |
| `fa-window-x` | WEB_APPLICATION | delete,remove |
| `fa-wizard` | WEB_APPLICATION | steps,progress |
| `fa-workflow` | WEB_APPLICATION | decision,branch,model,diagram |
| `fa-wrench` | WEB_APPLICATION | settings,fix,update |
| `fa-x-axis` | CHART |  |
| `fa-x-ray` | MEDICAL | exam,hospital |
| `fa-y-axis` | CHART |  |
| `fa-y1-axis` | CHART |  |
| `fa-y2-axis` | CHART |  |
| `fa-yen` | CURRENCY |  |
| `fa-axe` | CONSTRUCTION | tool,chop,wood,cutting,logging |
| `fa-blueprint-construction` | CONSTRUCTION | plan,design,architecture,drawing |
| `fa-bricks` | CONSTRUCTION | wall,building,materials,masonry |
| `fa-brush` | CONSTRUCTION | paint,tool,art,decorating,renovation |
| `fa-bucket` | CONSTRUCTION | paint,water,container,cleaning |
| `fa-bulldozer` | CONSTRUCTION | vehicle,earthmover,machine |
| `fa-compass-drafting` | CONSTRUCTION | design,draw,architecture,engineering,plan |
| `fa-crane` | CONSTRUCTION | lifting,crane,machine,site |
| `fa-crane-hook` | CONSTRUCTION | lifting,hook,equipment,machine |
| `fa-drill` | CONSTRUCTION | tool,boring,hardware,power |
| `fa-dump-truck` | CONSTRUCTION | vehicle,hauling,truck,site |
| `fa-excavator` | CONSTRUCTION | digging,vehicle,earthmoving |
| `fa-faucet` | CONSTRUCTION | plumbing,water,fixture,pipe,hardware |
| `fa-forklift` | CONSTRUCTION | warehouse,vehicle,loading,equipment |
| `fa-hammer` | CONSTRUCTION | tool,nail,repair,carpentry |
| `fa-hammer-brush` | CONSTRUCTION | renovation,tool,repair,painting |
| `fa-hard-hat` | CONSTRUCTION | safety,helmet,gear,worker |
| `fa-ladder` | CONSTRUCTION | climb,tool,repair,access |
| `fa-land-surveying` | CONSTRUCTION | measurement,survey,map,planning |
| `fa-mine-cart` | CONSTRUCTION | mining,cart,ore,underground,transport |
| `fa-mound` | CONSTRUCTION | earth,land,dirt,site |
| `fa-paint-can` | CONSTRUCTION | paint,tool,renovation,decorating,liquid |
| `fa-paint-roller` | CONSTRUCTION | paint,tool,decorating,renovation,wall |
| `fa-paver` | CONSTRUCTION | asphalt,road,vehicle,site |
| `fa-person-digging` | CONSTRUCTION | worker,dig,site |
| `fa-pipe` | CONSTRUCTION | plumbing,water,underground,flow |
| `fa-plexiglass` | CONSTRUCTION | material,barrier,clear,protective |
| `fa-portable-toilet` | CONSTRUCTION | bathroom,sanitation,portable,site |
| `fa-reel` | CONSTRUCTION | cable,electric,cord,tool |
| `fa-roadblock` | CONSTRUCTION | barrier,warning,traffic,site |
| `fa-ruler` | CONSTRUCTION | measure,tool,straight,line,drawing |
| `fa-ruler-combination` | CONSTRUCTION | measure,tool,angle,design,blueprint |
| `fa-safety-vest` | CONSTRUCTION | gear,protection,worker,safety |
| `fa-screwdriver` | CONSTRUCTION | tool,hardware,repair |
| `fa-sheet-metal` | CONSTRUCTION | material,metal,building,industrial |
| `fa-shovel` | CONSTRUCTION | dig,tool,earth |
| `fa-siding` | CONSTRUCTION | house,wall,cladding,exterior |
| `fa-toolbox` | CONSTRUCTION | tools,kit,repair,storage |
| `fa-tower-crane` | CONSTRUCTION | crane,building,skyline,equipment |
| `fa-traffic-cone` | CONSTRUCTION | safety,warning,traffic,barrier |
| `fa-triangle-person-digging` | CONSTRUCTION | warning,sign,digging,worker |
| `fa-trowel` | CONSTRUCTION | tool,masonry,plaster,cement |
| `fa-trowel-bricks` | CONSTRUCTION | masonry,tool,bricklaying,cement |
| `fa-trowel-stucco` | CONSTRUCTION | plaster,tool,finishing,wall |
| `fa-truck-container` | CONSTRUCTION | shipping,logistics,truck,freight,construction |
| `fa-truck-ladder` | CONSTRUCTION | ladder,vehicle,rescue |
| `fa-truck-pickup` | CONSTRUCTION | vehicle,transport,utility,haul |
| `fa-user-worker` | CONSTRUCTION | person,employee,safety |
| `fa-welding-mask` | CONSTRUCTION | safety,welding,mask,gear |
| `fa-wheelbarrow` | CONSTRUCTION | tool,carry,garden |
