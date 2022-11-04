/*
This is the roadmap for the next steps in Linkspeak

CAVEATS:
1- only available for android, apple integration needs <2 days
2- only available in english
3- no dark mode/night mode
4- reliance on 3rd party for ads(admob)
5- ugly native ads
6- no notification deep links
7- no cross sharing to other social apps
8- no pdf or word file sharing in chat
9- no error handling for text chat message sending(if text message fails to send)
10- doesnt get proper info from 3rd party logins
11- no apple sign in logic
12- all user data deleted upon profile deletion (law obligation)
  (maybe ambiguate the data instead and duplicate it as an anonymous user information)
13- no stickers, gifs, filters, audio,captions, etc.. in flares
14- no multi topic search
15- no web integration
16- no in app notification handling
(upon notification receival if app is in foreground)
17- fix admin daily login search screen bug

UPCOMING:
1- Linkspeak* subscription: no ads, multiple premium tier skin rotation each month
2- custom made app theme skins: 
  .can free trial only one skin
  .can trade skin for another skin once per each skin bought
3- Native ads from our private inventory of ads:
   .native post ads(legacy, billboard, article)
   .native flare collection ads
4- cross integration of some feature with other major apps
5- Marketplace tab for vendors,services,or skins from other users
  (may include 3rd party major vendors)
6- streams & stream sponsorship with split of earnings
7- games integration(3rd parties)
8- voice chat integration
9- vid chat integration
10- club group chat
11- translate foreign text content or video or text within picture
12- stamp media content upon saving
13- Legacy, Article, Billboard type posts
14- Extended text stickers in comments, replies, messages
15- sticker marketplace and trading
16- the more money spent by a user the hight the discount % pegged to the account
    users start with default 0% "spending discount" the higher the spending discount
    percentage the more money it takes to be spent for the percentage to rise.
    discount should be capped at 40-50%.
17- custom app launchers: 
    .current launcher
    .current launcher with gradient version
    .chosen primary color as background
18- different bottom navbars:(transparent, opaque, glossy)
    .rectangle
    .clipped rectangle
    .rotating circular wheel aligned at bottom
19- dedicated flare profile banner
20- club mentions
21- put all app strings in one file to prepare for internationalization
22- General: These common methods are to be refactored into general.dart
    .View Scheme
    .Session Scheme
    .End Session
    .Send Notification/Alert
    .Choose Gallery
    .Choose Camera
    .Initialize Post
    .Initialize Collection
    .Initialize Flare
    .Show Registration Dialog
    .Asset Widgets
23- Sortation:
    .Oldest
    .Least Likes
    .Most Replies
    .Least Replies
24- New store listing images/previews
25- Features Documentation presentation booklet & PDF
26- Database Architecture Codex binder & PDF
27- Design real life Linkspeak type profile card & other merchandise
28- Create internal code of conduct for the firm
29- Profiles & Clubs subscribe to be notified when new content released
30- Allow scanning post,flares,comment,reply codes to visit & view them
31- Fix Settings bar path clip white space
32- Show countdown next to admin banned users and prohibited clubs 
item  that counts down time left till user/club should be unbanned
subtracting adding duration of ban/prohibition to date of ban/prohibition

33- Single flare background and gradient color customization instead of black
34- Add comments to dart files & remove trailing commas
35- Write full feature documentation reference
36- Write database architecture codex (binder)
37- Write firestore and firebase storage directories (addresses & paths to docs & files)
38- Hide a flare collection from public: hidden and unhidden flare collections in flareProfile,
isHidden condition in flareTabWidget,
isHiddenCollection param in provider initialize
isHidden singleFlareWidget
isHidden flareChatWidget


39- Fix profileFlares.dart listview bug when overscroll is done too soon.
it might be related to flareprofiletab, try adding automatickeepaliveclientmixin to
flareprofiletab.
40- App badge notifications
41- somehow show clubname in postWidget if post is club post.
42- web platform integration.
43- more profiles in switchprofile.
44- fix flare profile screen disappearing screen bug
45- fix profile posts tab disappearing card bug (similar to flare profile tab bug)
(?)- Blacklist collection with blacklisted text to be censored similar to profanity
(?)- ML model that recognizes blacklisted faces or individuals to be blurred out 
from images or videos

Roadmap content stats/insights:
.Post stats
.flare stats
.flare collection stats
.flare profile stats
.club stats
.profile stats

Roadmap document subcollections display:
.Profiles
.Flare Profiles
.Clubs
.Posts
.Post Comments
.Post Comment Replies
.Flares
.Flare Comments
.Flare Comment Replies

DONE TASKS:
-

*/