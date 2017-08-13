//
//  AppDelegate.m
//  GLESViewHarness
//
//  Created by Jesse Bennett on 2/19/17.
//  Copyright © 2017 Jesse Bennett. All rights reserved.
//

#define CAIRO_HAS_GLESV2_SURFACE 1

#define CAIRO_HAS_NSGLES_FUNCTIONS 1

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <cairo.h>
#import <cairo-gl.h>

#define WIDTH 400
#define HEIGHT 400

#define LINEWIDTH 1.5

#define FILL_R 0.1
#define FILL_G 0.1
#define FILL_B 0.75
#define FILL_OPACITY 0.5

#define STROKE_R 0.1
#define STROKE_G 0.75
#define STROKE_B 0.1
#define STROKE_OPACITY 1.0

#define NUMPTS 6

#define CHEAT_SHADOWS 0         /* 1: use opaque gear shadows,
* 0: semitransparent shadows like qgears2 */

/* Set to 1 if the input can have superluminant pixels.  Cairo doesn't
 * produce them. */
#define DO_CLAMP_INPUT 0

#define pi 3.14159265358979323846264338327

/* Cairo pixel configuration.  This isn't tweakable, it just is. */
#define CAIROSDL_ASHIFT 24
#define CAIROSDL_RSHIFT 16
#define CAIROSDL_GSHIFT  8
#define CAIROSDL_BSHIFT  0
#define CAIROSDL_AMASK (255U << CAIROSDL_ASHIFT)
#define CAIROSDL_RMASK (255U << CAIROSDL_RSHIFT)
#define CAIROSDL_GMASK (255U << CAIROSDL_GSHIFT)
#define CAIROSDL_BMASK (255U << CAIROSDL_BSHIFT)

double scale = 1.0;

static double animpts[NUMPTS * 2];
static double deltas[NUMPTS * 2];
static int fill_gradient = 1;

//static cairo_user_data_key_t const CAIROSDL_TARGET_KEY[1] = {{1}};

static void
gear (cairo_t *cr,
	  double inner_radius,
	  double outer_radius,
	  int teeth,
	  double tooth_depth)
{
	int i;
	double r0, r1, r2;
	double angle, da;
	
	r0 = inner_radius;
	r1 = outer_radius - tooth_depth / 2.0;
	r2 = outer_radius + tooth_depth / 2.0;
	
	da = 2.0 * pi / (double) teeth / 4.0;
	
	cairo_new_path (cr);
	
	angle = 0.0;
	cairo_move_to (cr, r1 * cos (angle + 3 * da), r1 * sin (angle + 3 * da));
	
	for (i = 1; i <= teeth; i++) {
		angle = i * 2.0 * pi / (double) teeth;
		
		cairo_line_to (cr, r1 * cos (angle), r1 * sin (angle));
		cairo_line_to (cr, r2 * cos (angle + da), r2 * sin (angle + da));
		cairo_line_to (cr, r2 * cos (angle + 2 * da), r2 * sin (angle + 2 * da));
		
		if (i < teeth)
			cairo_line_to (cr, r1 * cos (angle + 3 * da),
						   r1 * sin (angle + 3 * da));
	}
	
	cairo_close_path (cr);
	
	cairo_move_to (cr, r0 * cos (angle + 3 * da), r0 * sin (angle + 3 * da));
	
	for (i = 1; i <= teeth; i++) {
		angle = i * 2.0 * pi / (double) teeth;
		
		cairo_line_to (cr, r0 * cos (angle), r0 * sin (angle));
	}
	
	cairo_close_path (cr);
}

static void
stroke_and_fill_animate (double *pts,
						 double *deltas,
						 int index,
						 int limit)
{
	double newpt = pts[index] + deltas[index];
	
	if (newpt <= 0) {
		newpt = -newpt;
		deltas[index] = (double) (((double)(rand()) / RAND_MAX) * 4.0 + 2.0);
	} else if (newpt >= (double) limit) {
		newpt = 2.0 * limit - newpt;
		deltas[index] = - (double) (((double)(rand()) / RAND_MAX) * 4.0 + 2.0);
	}
	pts[index] = newpt;
}

static void
stroke_and_fill_step (int w, int h)
{
	int i;
	
	for (i = 0; i < (NUMPTS * 2); i += 2) {
		stroke_and_fill_animate (animpts, deltas, i + 0, w);
		stroke_and_fill_animate (animpts, deltas, i + 1, h);
	}
}

static double gear1_rotation = 0.35;
static double gear2_rotation = 0.33;
static double gear3_rotation = 0.50;

void
trap_render (cairo_t *cr, cairo_surface_t *surface, int w, int h)
{
	double *ctrlpts = animpts;
	int len = (NUMPTS * 2);
	double prevx = ctrlpts[len - 2];
	double prevy = ctrlpts[len - 1];
	double curx = ctrlpts[0];
	double cury = ctrlpts[1];
	double midx = (curx + prevx) / 2.0;
	double midy = (cury + prevy) / 2.0;
	int i;
	int pass;
	
	cairo_set_fill_rule (cr, CAIRO_FILL_RULE_EVEN_ODD);
	
	cairo_set_source_rgba (cr, 0, 0, 0, 0);
	cairo_set_operator (cr, CAIRO_OPERATOR_SOURCE);
	cairo_rectangle (cr, 0, 0, w, h);
	cairo_fill (cr);
	cairo_set_operator (cr, CAIRO_OPERATOR_OVER);
	cairo_set_source_rgba (cr, 0.75, 0.75, 0.75, 1.0);
	cairo_set_line_width (cr, 1.0);
	
	cairo_save (cr); {
		cairo_scale (cr, (double) w / 512.0, (double) h / 512.0);
		
		cairo_save (cr); {
			cairo_translate (cr, -10.0, -10.0);
			cairo_translate (cr, 170.0, 330.0);
			cairo_rotate (cr, gear1_rotation);
			gear (cr, 30.0, 120.0, 20, 20.0);
			cairo_set_source_rgba (cr, 0.70, 0.70, 0.70, 0.70 + CHEAT_SHADOWS);
			cairo_fill (cr);
			cairo_restore (cr);
		}
		cairo_save (cr); {
			cairo_translate (cr, -10.0, -10.0);
			cairo_translate (cr, 369.0, 330.0);
			cairo_rotate (cr, gear2_rotation);
			gear (cr, 15.0, 75.0, 12, 20.0);
			cairo_set_source_rgba (cr, 0.70, 0.70, 0.70, 0.70 + CHEAT_SHADOWS);
			cairo_fill (cr);
			cairo_restore (cr);
		}
		cairo_save (cr); {
			cairo_translate (cr, -10.0, -10.0);
			cairo_translate (cr, 170.0, 116.0);
			cairo_rotate (cr, gear3_rotation);
			gear (cr, 20.0, 90.0, 14, 20.0);
			cairo_set_source_rgba (cr, 0.70, 0.70, 0.70, 0.70 + CHEAT_SHADOWS);
			cairo_fill (cr);
			cairo_restore (cr);
		}
		
		cairo_save (cr); {
			cairo_translate (cr, 170.0, 330.0);
			cairo_rotate (cr, gear1_rotation);
			gear (cr, 30.0, 120.0, 20, 20.0);
			cairo_set_source_rgb (cr, 0.75, 0.75, 0.75);
			cairo_fill_preserve (cr);
			cairo_set_source_rgb (cr, 0.25, 0.25, 0.25);
			cairo_stroke (cr);
			cairo_restore (cr);
		}
		cairo_save (cr); {
			cairo_translate (cr, 369.0, 330.0);
			cairo_rotate (cr, gear2_rotation);
			gear (cr, 15.0, 75.0, 12, 20.0);
			cairo_set_source_rgb (cr, 0.75, 0.75, 0.75);
			cairo_fill_preserve (cr);
			cairo_set_source_rgb (cr, 0.25, 0.25, 0.25);
			cairo_stroke (cr);
			cairo_restore (cr);
		}
		cairo_save (cr); {
			cairo_translate (cr, 170.0, 116.0);
			cairo_rotate (cr, gear3_rotation);
			gear (cr, 20.0, 90.0, 14, 20.0);
			cairo_set_source_rgb (cr, 0.75, 0.75, 0.75);
			cairo_fill_preserve (cr);
			cairo_set_source_rgb (cr, 0.25, 0.25, 0.25);
			cairo_stroke (cr);
			cairo_restore (cr);
		}
		
		cairo_restore (cr);
	}
	
	gear1_rotation += 0.01;
	gear2_rotation -= (0.01 * (20.0 / 12.0));
	gear3_rotation -= (0.01 * (20.0 / 14.0));
	
	stroke_and_fill_step (w, h);
	
	cairo_save(cr); {
		
		cairo_translate (cr, -10, -10);
		for (pass = 1; pass <= 2; pass++) {
			cairo_new_path (cr);
			cairo_move_to (cr, midx, midy);
			
			for (i = 2; i <= (NUMPTS * 2); i += 2) {
				double x2, x1 = (midx + curx) / 2.0;
				double y2, y1 = (midy + cury) / 2.0;
				
				prevx = curx;
				prevy = cury;
				if (i < (NUMPTS * 2)) {
					curx = ctrlpts[i + 0];
					cury = ctrlpts[i + 1];
				} else {
					curx = ctrlpts[0];
					cury = ctrlpts[1];
				}
				midx = (curx + prevx) / 2.0;
				midy = (cury + prevy) / 2.0;
				x2 = (prevx + midx) / 2.0;
				y2 = (prevy + midy) / 2.0;
				cairo_curve_to (cr, x1, y1, x2, y2, midx, midy);
			}
			cairo_close_path (cr);
			
			if (pass == 1) {
				cairo_set_source_rgba (cr, 0,0,0,77/255.0);
				cairo_fill (cr);
				cairo_translate (cr, 10, 10);
			}
		}
		
		if (fill_gradient) {
			
			double x1, y1, x2, y2;
			cairo_pattern_t *pattern;
			
		    cairo_fill_extents (cr, &x1, &y1, &x2, &y2);
			
			pattern = cairo_pattern_create_linear (x1, y1, x2, y2);
			
			cairo_pattern_set_filter (pattern, CAIRO_FILTER_NEAREST);
			
			cairo_pattern_add_color_stop_rgba (pattern, 0.0, 0.0, 0.0, 1.0, 0.75);
			
			cairo_pattern_add_color_stop_rgba (pattern, 1.0, 1.0, 0.0, 0.0, 1.0);
			
			cairo_move_to (cr, 0, 0);
			
			cairo_set_source (cr, pattern);
			
			cairo_pattern_destroy (pattern);
			
		} else {
			cairo_set_source_rgba (cr, FILL_R, FILL_G, FILL_B, FILL_OPACITY);
		}
		
		cairo_fill_preserve (cr);
		cairo_set_source_rgba (cr, STROKE_R, STROKE_G, STROKE_B, STROKE_OPACITY);
		cairo_set_line_width (cr, LINEWIDTH);
		cairo_stroke (cr);
		
		 
		cairo_restore(cr);
		
	}
	
	cairo_surface_flush(surface);

}

@interface AppDelegate ()

@end

@implementation AppDelegate {
	float _curRed;
	BOOL _increasing;
	cairo_surface_t *surface;
	cairo_t *cr;
	cairo_device_t *device;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
	
	_increasing = YES;
	_curRed = 0.0;
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
 
	EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]; 
	GLKView *view = [[GLKView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	view.context = context;
	view.delegate = self;
	view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	view.drawableStencilFormat = GLKViewDrawableStencilFormat8;
	view.drawableMultisample = GLKViewDrawableMultisampleNone;
	view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
	
	UIViewController* vc = [[UIViewController alloc]initWithNibName:nil bundle:nil];
	
	device = cairo_nsgles_device_create ((__bridge void *)(context));
	
	cairo_gl_device_set_thread_aware(device, TRUE);
	
	surface = cairo_gl_surface_create_for_view (device, (__bridge void *)(self), 400, 400);
	
	cr = cairo_create (surface);
	
	[self.window addSubview:view];
	self.window.rootViewController = vc;
	
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];
	
	view.enableSetNeedsDisplay = NO;
	CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
	[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	
	return YES;
	
}

- (void)render:(CADisplayLink*)displayLink {
	
	@autoreleasepool {
	
	GLKView * view = [self.window.subviews objectAtIndex:0];
	
	trap_render(cr, surface, WIDTH, HEIGHT);
	
	[view display];
		
	}
}


- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end