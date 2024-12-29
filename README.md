#  Fetch Take-Home - Peyton Shetler


### Steps to Run the App
- Download the project and run it :)

### Focus Areas: What specific areas of the project did you prioritize? Why did you choose to focus on these areas?
- I don't necessarily think this is unique, but I focused heavily on data modeling in the beginning. The idea behind that is to keep the UI as data "agnostic" as possible. If the UI layer gets bogged down with transforming data, etc., it becomes distracting, hard to read for other devs, and it just shouldn't be there, haha. 

### Time Spent: Approximately how long did you spend working on this project? How did you allocate your time?
- Probably 4-5 hours on the coding portion. I had to refresh myself on a lot of SwiftUI, haha.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
1. Initially I started off with a LazyVStack + Scrollview, but then switched to a List component as I read a few sources that the LazyVStack/Scrollview is more memory intensive.

2. I was *really* excited to use the `AsyncImage` component for the first time but, apparently it doesn't cache images which was a letdown. So I made my own custom View that handles caching, loading from disk/URL, etc. I preferred doing that work in a separate component as opposed to loading/caching images in the Recipe List's view model because I didn't want to traverse a potentially large array of data whenever I needed to access a specific Recipe instance. 


### Weakest Part of the Project: What do you think is the weakest part of your project?

1. For one, the UI itself, haha. I don't think it looks good. 
2. I feel like somehow I could've been more clever with the `RecipeNetworkVMState` enum by using associated types. But when I tried it, it always felt forced and too "over the top".
3. Perhaps the biggest weakness, if that I haven't spent a lot of time looking at SwiftUI's performance. So I don't know where it's weak spots are "under the hood". Am I causing SwiftUI to create too many views, thus negatively affecting performance? I'm not sure yet, but I hope not 🤷🏻‍♂️ 

### Additional Information: Is there anything else we should know? Feel free to share any insights or constraints you encountered.
- I'd love to know a cleaner way to handle empty states in a SwiftUI List without resorting to the overlay modifier. It feels a little hacky. Althought maybe it's the best approach. I just needed something that still gave me access to List's refreshable modifier.
