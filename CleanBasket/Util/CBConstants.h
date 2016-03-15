#import <Foundation/Foundation.h>

typedef enum serverConstant : NSUInteger {
    CBServerConstantSessionExpired = 0,
    CBServerConstantSuccess,
    CBServerConstantError,
    CBServerConstantEmailError,
    CBServerConstantPasswordError,
    CBServerConstantAccountValid,
    CBServerConstantAccountInvalid = 6,
    CBServerConstantAccountEnabled = 8,
    CBServerConstantAccountDisabled,

    CBServerConstantsRoleAdmin = 10,
    CBServerConstantsRoleDeliverer,
    CBServerConstantsRoleMember,
    CBServerConstantsRoleInvalid,
    CBServerConstantsImageWriteError,
    CBServerConstantsImpossible,
    CBServerConstantsAccountDuplication,
    CBServerConstantsSessionValid = 17,
    CBServerConstantsAreaUnavailable = 18,
    CBServerConstantsDateUnavailable = 19,

    CBServerConstantsPushAssignPickup = 100,
    CBServerConstantsPushAssignDropoff,
    CBServerConstantsPushSoonPickup,
    CBServerConstantsPushSoonDropoff = 103,

    CBServerConstantsPushOrderAdd = 200,
    CBServerConstantsPushOrderCancel,
    CBServerConstantsPushPickupComplete,
    CBServerConstantsPushDropoffComplete,
    CBServerConstantsPushMemberJoin,
    CBServerConstantsPushDelivererJoin,
    CBServerConstantsPushChangeAccountEnabled = 206,

    CBServerConstantsDuplication = 207,
    CBServerConstantsInvalid = 208
} ServerContant ;


#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif
#define CleanBasketMint [UIColor colorWithRed:(131/255.0) green:(219/255.0) blue:(209/255.0) alpha:1.0]
#define CleanBasketRed Rgb2UIColor(249, 105, 126)
#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]
#define SCREEN_RECT [[UIScreen mainScreen] bounds]
#define DEVICE_WIDTH SCREEN_RECT.size.width
#define DEVICE_HEIGHT SCREEN_RECT.size.height
#define TAPBAR_HEIGHT 49
#define NAV_STATUS_HEIGHT 64
#define UltraLightGray Rgb2UIColor(238, 238, 238)
#define NEW_INDEX 9999
#define isiPhone5 ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
#define iPhone5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define COUPON_HEIGHT 162
#define APP_NAME_STRING @"CleanBasket"


#if defined(CBTEST)
#define CB_SERVER_URL @"http://52.79.39.100:8080/"
#else
#define CB_SERVER_URL @"http://www.cleanbasket.co.kr/"
#endif