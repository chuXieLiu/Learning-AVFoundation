//
//  ViewController.m
//  TextToSpeech
//
//  Created by c_xie on 16/3/20.
//  Copyright © 2016年 CX. All rights reserved.
//

#import "ViewController.h"
#import "CXStringTableViewCell.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVSpeechSynthesizerDelegate>

@property (nonatomic,strong) AVSpeechSynthesizer *speechSynthesizer;

@property (nonatomic,strong) NSArray *strings;

@property (nonatomic,strong) NSMutableArray *stringList;

@property (nonatomic,strong) NSArray *voices;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _speechSynthesizer = [[AVSpeechSynthesizer alloc] init];
    _speechSynthesizer.delegate = self;
    
    _strings = @[
                 @"锄禾日当午,汗滴禾下土",
                 @"谁知盘中餐,粒粒皆辛苦",
                 @"锄禾日当午,汗滴禾下土,谁知盘中餐,粒粒皆辛苦",
                 @"锄禾日当午,汗滴禾下土,谁知盘中餐,粒粒皆辛苦",
                 @"锄禾日当午,汗滴禾下土,谁知盘中餐,粒粒皆辛苦",
                 @"锄禾日当午,汗滴禾下土,谁知盘中餐,粒粒皆辛苦",
                 @"锄禾日当午,汗滴禾下土,谁知盘中餐,粒粒皆辛苦",
                 @"锄禾日当午,汗滴禾下土,谁知盘中餐,粒粒皆辛苦",
                 @"锄禾日当午,汗滴禾下土,谁知盘中餐,粒粒皆辛苦",
                 @"锄禾日当午,汗滴禾下土,谁知盘中餐,粒粒皆辛苦",
                 @"锄禾日当午,汗滴禾下土,谁知盘中餐,粒粒皆辛苦",
                 ];
    _stringList = @[].mutableCopy;
    
    _voices = @[
                [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-HK"],
                [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"]
                ];
    
    self.tableView.estimatedRowHeight = 100.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self beginSpeech];
}


- (void)beginSpeech
{
    for (int i = 0; i < _strings.count; i++) {
        AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:_strings[i]];
        utterance.voice = _voices[i % 2];
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
        utterance.pitchMultiplier = 0.8f;
        utterance.postUtteranceDelay = 0.1f;
        [_speechSynthesizer speakUtterance:utterance];
    }
}

#pragma mark - AVSpeechSynthesizerDelegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
    [_stringList addObject:utterance.speechString];

    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_stringList.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _stringList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CXStringTableViewCell *cell = nil;
    if (indexPath.row % 2 == 0 || indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"left"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"right"];
    }
    cell.titleLabel.text = _stringList[indexPath.row];
    return cell;
}


@end







/*
 "[AVSpeechSynthesisVoice 0x978a0b0] Language: th-TH",
 "[AVSpeechSynthesisVoice 0x977a450] Language: pt-BR",
 "[AVSpeechSynthesisVoice 0x977a480] Language: sk-SK",
 "[AVSpeechSynthesisVoice 0x978ad50] Language: fr-CA",
 "[AVSpeechSynthesisVoice 0x978ada0] Language: ro-RO",
 "[AVSpeechSynthesisVoice 0x97823f0] Language: no-NO",
 "[AVSpeechSynthesisVoice 0x978e7b0] Language: fi-FI",
 "[AVSpeechSynthesisVoice 0x978af50] Language: pl-PL",
 "[AVSpeechSynthesisVoice 0x978afa0] Language: de-DE",
 "[AVSpeechSynthesisVoice 0x978e390] Language: nl-NL",
 "[AVSpeechSynthesisVoice 0x978b030] Language: id-ID",
 "[AVSpeechSynthesisVoice 0x978b080] Language: tr-TR",
 "[AVSpeechSynthesisVoice 0x978b0d0] Language: it-IT",
 "[AVSpeechSynthesisVoice 0x978b120] Language: pt-PT",
 "[AVSpeechSynthesisVoice 0x978b170] Language: fr-FR",
 "[AVSpeechSynthesisVoice 0x978b1c0] Language: ru-RU",
 "[AVSpeechSynthesisVoice 0x978b210] Language: es-MX",
 "[AVSpeechSynthesisVoice 0x978b2d0] Language: zh-HK",  中文(香港) 粤语
 "[AVSpeechSynthesisVoice 0x978b320] Language: sv-SE",
 "[AVSpeechSynthesisVoice 0x978b010] Language: hu-HU",
 "[AVSpeechSynthesisVoice 0x978b440] Language: zh-TW",  中文(台湾)
 "[AVSpeechSynthesisVoice 0x978b490] Language: es-ES",
 "[AVSpeechSynthesisVoice 0x978b4e0] Language: zh-CN",  中文(普通话)
 "[AVSpeechSynthesisVoice 0x978b530] Language: nl-BE",
 "[AVSpeechSynthesisVoice 0x978b580] Language: en-GB",  英语(英国)
 "[AVSpeechSynthesisVoice 0x978b5d0] Language: ar-SA",
 "[AVSpeechSynthesisVoice 0x978b620] Language: ko-KR",
 "[AVSpeechSynthesisVoice 0x978b670] Language: cs-CZ",
 "[AVSpeechSynthesisVoice 0x978b6c0] Language: en-ZA",
 "[AVSpeechSynthesisVoice 0x978aed0] Language: en-AU",
 "[AVSpeechSynthesisVoice 0x978af20] Language: da-DK",
 "[AVSpeechSynthesisVoice 0x978b810] Language: en-US",  英语(美国)
 "[AVSpeechSynthesisVoice 0x978b860] Language: en-IE",
 "[AVSpeechSynthesisVoice 0x978b8b0] Language: hi-IN",
 "[AVSpeechSynthesisVoice 0x978b900] Language: el-GR",
 "[AVSpeechSynthesisVoice 0x978b950] Language: ja-JP" )
 */
