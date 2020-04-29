# wp-update-reg-test

This is a Shell script application to make visual regrassion Test for Wordpress after update.

In simple words to check if something change on your WP after update 

### Based on:
1. WP-CLI
2. BackStopJS(Visual Regrestion Testing)

### How it works

A. Create a new backstop config JSON file
this will crawl the website DOM and create backstop config JSON file 

B. start the approval process for the present visual state of the website

C. Start plugin update 

D. After plugin update check for visual changes 

E. if Changes are found then present the issues  and ask if user want to continue
