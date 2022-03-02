//
//  JSTileMap.h
//  TMXMapSample
//
//  Created by Jeremy on 6/11/13.
//  Copyright (c) 2013 Jeremy. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>

#import "LFCGzipUtility.h"

enum
{
	TMXLayerAttributeNone	= 1 << 0,
	TMXLayerAttributeBase64	= 1 << 1,
	TMXLayerAttributeGzip	= 1 << 2,
	TMXLayerAttributeZlib	= 1 << 3,
};

typedef enum
{
	TMXPropertyNone,
	TMXPropertyMap,
	TMXPropertyLayer,
	TMXPropertyObjectGroup,
	TMXPropertyObject,
	TMXPropertyTile,
	TMXPropertyImageLayer
} PropertyType;

typedef enum
{
	kTileDiagonalFlag		= 0x20000000,
	kTileVerticalFlag		= 0x40000000,
	kTileHorizontalFlag		= 0x80000000,
	
	kFlippedAll				= (kTileHorizontalFlag | kTileVerticalFlag | kTileDiagonalFlag),
	kFlippedMask			= ~(kFlippedAll),
} TMXTileFlags;

typedef enum 
{
	OrientationStyle_Orthogonal,
	OrientationStyle_Isometric
} OrientationStyle;


@interface TMXTilesetInfo : NSObject <NSCoding>

@property (readonly, nonatomic) NSString* name;
@property (readonly, nonatomic) unsigned int firstGid;
@property (readonly, nonatomic) CGSize tileSize;
@property (readonly, nonatomic) CGSize unitTileSize;
@property (readonly, nonatomic) unsigned int spacing;
@property (readonly, nonatomic) unsigned int margin;
@property (readonly, nonatomic) NSString* sourceImage;
@property (readonly, nonatomic) CGSize imageSize;
@property (readonly, nonatomic) int atlasTilesPerRow;
@property (readonly, nonatomic) int atlasTilesPerCol;
@property (readonly, nonatomic) SKTexture* atlasTexture;

-(instancetype)initWithGid:(int)gid attributes:(NSDictionary*)attributes;
-(void)setSourceImage:(NSString *)sourceImage;

-(int)rowFromGid:(int)gid;
-(int)colFromGid:(int)gid;
-(SKTexture*)textureForGid:(int)gid;

/** Given the location of the upper left corner of a tile in this tileset, 
    returns a new SKTexture for that tile. */
-(SKTexture*)textureAtPoint:(CGPoint)p;

@end

@class TMXLayer;

@interface TMXLayerInfo : NSObject <NSCoding>
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) CGSize layerGridSize;
@property (assign, nonatomic) int* tiles;
@property (assign, nonatomic) BOOL visible;
@property (assign, nonatomic) CGFloat opacity;
@property (assign, nonatomic) unsigned int minGID;
@property (assign, nonatomic) unsigned int maxGID;
@property (strong, nonatomic) NSMutableDictionary *properties;
@property (assign, nonatomic) CGPoint offset;
@property (assign, nonatomic) TMXLayer* layer;

-(int)tileGidAtCoord:(CGPoint)coord;

// debugging
- (void)logLayerGIDs;

@end

@interface TMXImageLayer : NSObject <NSCoding>
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSMutableDictionary *properties;
@property (strong, nonatomic) NSString* imageSource;
//@property (strong, nonatomic) NSString* transparencyColor;	// Will maybe support this in the future.  I think this is what the "trans" property is...
@end


@interface TMXObjectGroup : NSObject <NSCoding>
@property (strong, nonatomic) NSString *groupName;
@property (assign, nonatomic) CGPoint positionOffset;
@property (strong, nonatomic) NSMutableArray *objects;
@property (strong, nonatomic) NSMutableDictionary *properties;

- (NSDictionary *)objectNamed:(NSString *)objectName;	// returns the first object with the specified name. Nil, if no object matches
- (NSArray *)objectsNamed:(NSString *)objectName;		// returns an NSArray of objects with the specified name
- (id)propertyNamed:(NSString *)propertyName;			// returns the property with the specified name

@end

@class JSTileMap;

@interface TMXLayer : SKNode
@property (strong, nonatomic) TMXLayerInfo* layerInfo;
@property (strong, nonatomic) NSMutableSet* tileInfo;  // contains TMXTilesetInfo objects
@property (assign, nonatomic) CGSize mapTileSize;

/** Returns the width of the layer (layerGridSize.width * mapTileSize.width) */
@property (readonly,nonatomic) CGFloat layerWidth;

/** Returns the height of the layer (layerGridSize.height * mapTileSize.height) */
@property (readonly,nonatomic) CGFloat layerHeight;

/** Returns the JSTileMap that contains this layer */
@property (weak, nonatomic) JSTileMap* map;

- (CGPoint)pointForCoord:(CGPoint)coord;
- (CGPoint)coordForPoint:(CGPoint)point;

- (void)removeTileAtCoord:(CGPoint)coord;
- (SKSpriteNode*)tileAt:(CGPoint)point;
- (SKSpriteNode*)tileAtCoord:(CGPoint)coord;
- (int)tileGidAt:(CGPoint)point;
- (id) propertyWithName:(NSString*)name;
- (NSDictionary*)properties;

@end


@interface JSTileMap : SKNode <NSXMLParserDelegate>

@property (assign, nonatomic) CGSize mapSize;
@property (assign, nonatomic) CGSize tileSize;
@property (assign, nonatomic) PropertyType parentElement;
@property (assign, nonatomic) int parentGID;
@property (assign, nonatomic) unsigned int orientation;

// minimum and maximum range of zPositioning of the map.
@property (readonly) CGFloat minZPositioning;
@property (readonly) CGFloat maxZPositioning;

// tmx filename
@property (strong, nonatomic) NSString *filename;

// tmx resource path
@property (strong, nonatomic) NSString *resources;

// tilesets
@property (strong, nonatomic) NSMutableArray* tilesets;

// tile properties
@property (strong, nonatomic) NSMutableDictionary* tileProperties;

// properties
@property (strong, nonatomic) NSMutableDictionary* properties;

// layers
@property (strong, nonatomic) NSMutableArray* layers;

// image layers
@property (strong, nonatomic) NSMutableArray* imageLayers;

// object groups
@property (strong, nonatomic) NSMutableArray* objectGroups;

// xml tile gids
@property (strong, nonatomic) NSMutableArray* gidData;

+ (JSTileMap*)mapNamed:(NSString*)mapName;
+ (JSTileMap*)mapNamed:(NSString*)mapName withBaseZPosition:(CGFloat)baseZPosition andZOrderModifier:(CGFloat)zOrderModifier;

-(TMXLayer*)layerNamed:(NSString*)name;
-(TMXObjectGroup*)groupNamed:(NSString*)name;

-(TMXTilesetInfo*)tilesetInfoForGid:(int)gID;
-(NSDictionary*)propertiesForGid:(int)gID;

// debugging
- (void)logGIDs;


@end
