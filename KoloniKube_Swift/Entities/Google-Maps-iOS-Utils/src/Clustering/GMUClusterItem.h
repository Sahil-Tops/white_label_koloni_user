/* Copyright (c) 2016 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

/**
 * This protocol defines the contract for a cluster item.
 */
@protocol GMUClusterItem <NSObject>

/**
 * Returns the position of the item.
 */
@property(nonatomic, readonly) CLLocationCoordinate2D position;

@property(nonatomic, readonly) NSString *strName;

@property(nonatomic, readonly) NSString *strIndex;

@property(nonatomic, readonly) UIImage *assetImage;

@property(nonatomic, readonly) UIColor *color;

@end

