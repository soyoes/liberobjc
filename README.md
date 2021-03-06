liberobjc
=========

Rock your OBJC like script language

# Goals
* Simplify View rendering
* Write OBJC code like script languages.
* Use Style sheets to define styles of views.
* Make it easy to define styles like
    * borderLeft, borderRight ... with different styles
    * inner shadow.
    * cornerRadius > borderLeft...
* Simplify some works, so you can define styles like this way
    * .border = "1 #33333399"       #width=1, color=#333333, alpha=99/255
    * .bgcolor = "#333333:0 #888888:1"  #gradient %0=#333, %100=#888
    * .shadow = "5 8 10 #666666"    #shadow offset=5,8 radius=10 color=#666666
    * .shadow = "inset 5 5 5"       #inset shadow with offset & radius, color=darkgray
    * .font = "Arial,18"            #font name=Arail, size=18
    * .outline = "1 #555555"
    * .scale = 2,1                  #transform to 200%, 100%
    * .flip = "H"                   # or "V", horizontal/vertical flip
    * .rotate = 90|180|270 ...   
    * text editing | display features: .nowrap ,.truncate, .editable
    * layout features : padding, margin, space, paddingLeft, marginLeft....
# Examples

```objective-c

- (void)viewDidLoad
{
    [super viewDidLoad];

    View *panel = vbox(nil, (Styles){}, self.view);
        
    //Draw a row with 3 cells
    vbox(@[
        hbox(nil, (Style){.w=98,.bgcolor="#FF0000"}, nil),
        hbox(nil, (Style){.w=98,.bgcolor="#FFFF00"}, nil),
        hbox(nil, (Style){.w=98,.bgcolor="#FF00FF"}, nil)
    ], (Style){.padding=10,.h=100,.space=3},panel);

    //Draw a vertical layout with 3 rows
    vbox(@[
        vbox(nil, (Style){.h=40,.bgcolor="60,180,255"}, nil),   //RGB
        vbox(nil, (Style){.h=40,.bgcolor="#FF9933"}, nil),  //RGB HEX
        vbox(nil, (Style){.h=40,.bgcolor="#FF993388"}, nil) //RGBA HEX
    ], (Style){.padding=10,.h=140,.space=5},panel);
    
    //Draw a text label
    vbox(@[
        label(@"Its a test", (Style){.color="#333333",.nowrap=YES,.truncate=NO,fontName="Arail"}, nil),
    ], (Style){.padding=10,.w=320,.h=40},panel);
    

    //Draw a image, & change the src while tapped.
    vbox(@[
         [img(@"layout_detail.png", (Style){}, nil) bind:@"tap"
                                            handler:^void (UIGestureRecognizer* o){
                                                View *v = (View *)o.view;
                                                if([v.src isEqualToString:@"layout_detail.png"])
                                                    [v setImage:@"layout_detail_b.png"];
                                                else
                                                    [v setImage:@"layout_detail.png"];
                                            } options:nil],
    ], (Style){.padding=10,.w=100,.h=100},panel);

    //Draw a box with 'CSS' style
    View * b = vbox(nil, (Style){.h=30,.bgcolor="#00FFFF",.style="testStyle"} , panel);
    //CSS is not available for the lastest version,  will be recovered soon.
    
    //Draw a list view from array
    list(@[@{@"v":@"row 1"},@{@"v":@"row 2"},@{@"v":@"row 3"}], 
        ^void(NSDictionary*d, View* row,int idx){
            [row setText:d[@"v"]];
        }, (Style){}, panel);

    //Draw borderBottom/left.. with different styles.
    //Draw innerShadow
    vbox(nil, (Styles){.x=30,.y=40,.h=100,.w=100,.margin=50,
            .borderLeft="20 #33CCFF",
            .borderTop="10 #CCFF33",
            .borderRight="20 #FFCC33",
            .borderBottom="10 #FF33CC",
            //.border="10 #000000",
            .shadow="inset 15 15 5",
            .cornerRadius=40,
            .outline="1 2 #999999",
            .ID="myrect"},panel);
    
}

```

The result of the last example

![Image](http://soyoes.com/test/liberobjc-example1.png)

In your styles.json

``` css

{
    "testStyle" : {
        "border":"1 #FFFF00",
        "shadow":"1 1 #000000"
    }

}

```
