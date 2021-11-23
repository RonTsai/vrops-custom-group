# vrops-custom-group


Automatically create custom dynamic groups in vROps server as per vCenter Tags and vCenter Custom Attribute



The initial script was developed by my colleague Sajal Debnath.
For more details check the blog at https://sajaldebnath.com/posts/automatically-create-custom-groups-vrops-per-vcenter-tags/

But his script was not valid on vRops8+

I have based his script to modify the vCenter Tags part, and add another script for Custom Attribute.

So in here.
You can create custom attribute by vCenter Tags and also can create by Cusotm Attribute.
1.  Tag data set example, it will create custom group "VCSA". with criteria "VC-Mon" 
    ,custom group "tag". with criteria "test" ... etc 

    {
        "tagName":  "VCSA",
        "categoryName":  "VC-Mon"
    },
    {
        "tagName":  "New Testing Tag",
        "categoryName":  "interconnect-appliances"
    },
    {
        "tagName":  "tag",
        "categoryName":  "test"
    },
    
  
 2. Custom Attribute set example, it will create custom group "ASSET-vRa8" with critera (attribute key) - ASSET equal (attribute value) - vRa8 
    , "ASSET-vRa7" with critera (attribute key) - ASSET equal (attribute value) - vRa7   etc...


    {
        "attrKey":  "ASSET",
        "attrValue":  "vRa8"
    },
    {
        "attrKey":  "ASSET",
        "attrValue":  "vRa7"
    }

   
