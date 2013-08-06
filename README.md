liberobjc
=========

a library for objc


# Goals
* Simplify View rendering
* Write OBJC code like script languages.
* Use Style sheets to define styles of views.


# Examples

```objective-c

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    //Draw a row with 3 cells
    vbox(@[
        hbox(nil, @{@"w":@98,@"bgcolor":[UIColor redColor]}, nil),
        hbox(nil, @{@"w":@98,@"bgcolor":@"#FFFF00"}, nil),
        hbox(nil, @{@"w":@98,@"bgcolor":@"#00FF00CC"}, nil)
    ], @{@"padding":@10,@"h":@100,@"space":@3},self.view);

    //Draw a vertical layout with 3 rows
    vbox(@[
        vbox(nil, @{@"h":@40,@"bgcolor":@"60,180,255"}, nil),
        vbox(nil, @{@"h":@40,@"bgcolor":[UIColor orangeColor]}, nil),
        vbox(nil, @{@"h":@40,@"bgcolor":[UIColor purpleColor]}, nil)
    ], @{@"padding":@10,@"h":@140,@"space":@5},self.view);
    
    //Draw a text label
    vbox(@[
        label(@"Its a test", @{@"color":[UIColor redColor]}, nil),
    ], @{@"padding":@10,@"w":@320,@"h":@40},self.view);
    

    //Draw a image, & change the src while tapped.
    vbox(@[
         [img(@"layout_detail.png", @{}, nil) bind:@"tap"
                                            handler:^void (UIGestureRecognizer* o){
                                                View *v = (View *)o.view;
                                                if([v.src isEqualToString:@"layout_detail.png"])
                                                    [v setImage:@"layout_detail_b.png"];
                                                else
                                                    [v setImage:@"layout_detail.png"];
                                            } options:nil],
    ], @{@"padding":@10,@"w":@100,@"h":@100},self.view);

    //Draw a box with 'CSS' style
    View * b = vbox(nil, @{@"h":@30,@"bgcolor":[UIColor blueColor],@"css":@"testStyle"} , self.view);
    
    //Draw a list view from array
    list(@[@{@"v":@"row 1"},@{@"v":@"row 2"},@{@"v":@"row 3"}], 
        ^void(NSDictionary*d, View* row,int idx){
            [row setText:d[@"v"]];
        }, nil, self.view);

    //Draw borderBottom.
    vbox(nil, @{@"h":@30,@"bgcolor":[UIColor yellowColor],@"borderBottom":@"5 #000000"} , self.view);
    
}



```

In your styles.json

``` css

{
    "testStyle" : {
        "border":"1 #FFFF00",
        "shadow":"1 1 #000000"
    }

}

```
