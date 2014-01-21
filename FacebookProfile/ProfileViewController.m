//
//  ProfileViewController.m
//  FacebookProfile
//
//  Created by SDT-1 on 2014. 1. 21..
//  Copyright (c) 2014년 SDT-1. All rights reserved.
//


#import "ProfileViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#define FACEBOOK_APPID @"1446711568878033"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UITextView *aboutView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateLabel;

@property (strong, nonatomic) ACAccount *facebookAccount;

@end

@implementation ProfileViewController



- (void)showMyProfile
{
    ACAccountStore *accoutStore = [[ACAccountStore alloc]init];
    ACAccountType *accountType = [accoutStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierFacebook];
    
    NSDictionary *options = @{ACFacebookAppIdKey:FACEBOOK_APPID,
                              ACFacebookPermissionsKey:@[@"user_about_me"],
                              ACFacebookAudienceKey:ACFacebookAudienceEveryone};
    
    [accoutStore requestAccessToAccountsWithType:accountType options:options completion:^(BOOL granted, NSError *error){
        if(granted)
        {
            NSArray *accounts = [accoutStore accountsWithAccountType:accountType];
            self.facebookAccount = [accounts lastObject];
            
            [self requestProfile];
            
            
        }
        else
        {
            NSLog(@"승인 실패 : %@",error);
        }
    }];
    
}

- (void)requestProfile
{   //페이스북 서비스 타입 지정
    NSString *serviceType = SLServiceTypeFacebook;
    //정보를 얻어오기 위한 GET
    SLRequestMethod method = SLRequestMethodGET;
    //그래프 API를 적용한 URL
    NSURL *url = [NSURL URLWithString:@"https://graph.facebook.com/me"];
    //파라미터
    NSDictionary *param = @{@"fields":@"picture,name,about,gender,link,updated_time"};
    SLRequest *request = [SLRequest requestForServiceType:serviceType requestMethod:method URL:url parameters:param];
    request.account = self.facebookAccount;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if(nil != error)
        {
            NSLog(@"프로필 정보 얻기 실패 : %@",error);
            return;
        }
        
        __autoreleasing NSError *parseError = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&parseError];
        
        NSDictionary *picture = result[@"picture"][@"data"];
        NSString *imageUrlStr = picture[@"url"];
        
        NSURL *url = [NSURL URLWithString:imageUrlStr];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.nameLabel.text =result[@"name"];
            self.aboutView.text=result[@"about"];
            self.genderLabel.text=result[@"gender"];
            self.updateLabel.text=result[@"updated_time"];
            self.linkLabel.text=result[@"link"];
            self.profileImage.image=image;
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self showMyProfile];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
