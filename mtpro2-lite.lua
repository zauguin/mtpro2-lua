-- The original mtpro2 package has a bunch of option:
--  - complete / lite: not applicable, we are always "lite"
--  - uprightGreek / slantedGreek: Both versions are always loaded, which is used depends on unicode-math
--  - compatiblegreek: n/a, handled by unicode-math
--  - caligraphic font selection: Currently none are supported, load a calligraphic font separately
--  - automaticsubscriptcorrection: TODO
--  - sloperators: Could be added
--  - Others: Not yet considered

local abs = math.abs

local designsize = 655360

local function get_parameters(kind, mathconstants, _param_letters, param_symbols, param_large)
  if kind == 'xetex' then
    return {
      quad = param_symbols.quad,
      slant = param_symbols.slant,
      space = param_symbols.space,
      space_shrink = param_symbols.space_shrink,
      space_stretch = param_symbols.space_stretch,
      x_height = param_symbols.x_height,
      extra_space = param_symbols.extra_space,
      [8] = 0,
      [9] = 0,
      [10] = mathconstants.ScriptPercentScaleDown,
      [11] = mathconstants.ScriptScriptPercentScaleDown,
      [12] = mathconstants.DelimitedSubFormulaMinHeight,
      [13] = mathconstants.DisplayOperatorMinHeight,
      [14] = mathconstants.MathLeading,
      [15] = mathconstants.AxisHeight,
      [16] = mathconstants.AccentBaseHeight,
      [17] = mathconstants.FlattenedAccentBaseHeight,
      [18] = mathconstants.SubscriptShiftDown,
      [19] = mathconstants.SubscriptTopMax,
      [20] = mathconstants.SubscriptBaselineDropMin,
      [21] = mathconstants.SuperscriptShiftUp,
      [22] = mathconstants.SuperscriptShiftUpCramped,
      [23] = mathconstants.SuperscriptBottomMin,
      [24] = mathconstants.SuperscriptBaselineDropMax,
      [25] = mathconstants.SubSuperscriptGapMin,
      [26] = mathconstants.SuperscriptBottomMaxWithSubscript,
      [27] = mathconstants.SpaceAfterScript,
      [28] = mathconstants.UpperLimitGapMin,
      [29] = mathconstants.UpperLimitBaselineRiseMin,
      [30] = mathconstants.LowerLimitGapMin,
      [31] = mathconstants.LowerLimitBaselineDropMin,
      [32] = mathconstants.StackTopShiftUp,
      [33] = mathconstants.StackTopDisplayStyleShiftUp,
      [34] = mathconstants.StackBottomShiftDown,
      [35] = mathconstants.StackBottomDisplayStyleShiftDown,
      [36] = mathconstants.StackGapMin,
      [37] = mathconstants.StackDisplayStyleGapMin,
      [38] = mathconstants.StretchStackTopShiftUp,
      [39] = mathconstants.StretchStackBottomShiftDown,
      [40] = mathconstants.StretchStackGapAboveMin,
      [41] = mathconstants.StretchStackGapBelowMin,
      [42] = mathconstants.FractionNumeratorShiftUp,
      [43] = mathconstants.FractionNumeratorDisplayStyleShiftUp,
      [44] = mathconstants.FractionDenominatorShiftDown,
      [45] = mathconstants.FractionDenominatorDisplayStyleShiftDown,
      [46] = mathconstants.FractionNumeratorGapMin,
      [47] = mathconstants.FractionNumeratorDisplayStyleGapMin,
      [48] = mathconstants.FractionRuleThickness,
      [49] = mathconstants.FractionDenominatorGapMin,
      [50] = mathconstants.FractionDenominatorDisplayStyleGapMin,
      [51] = mathconstants.SkewedFractionHorizontalGap,
      [52] = mathconstants.SkewedFractionVerticalGap,
      [53] = mathconstants.OverbarVerticalGap,
      [54] = mathconstants.OverbarRuleThickness,
      [55] = mathconstants.OverbarExtraAscender,
      [56] = mathconstants.UnderbarVerticalGap,
      [57] = mathconstants.UnderbarRuleThickness,
      [58] = mathconstants.UnderbarExtraDescender,
      [59] = mathconstants.RadicalVerticalGap,
      [60] = mathconstants.RadicalDisplayStyleVerticalGap,
      [61] = mathconstants.RadicalRuleThickness,
      [62] = mathconstants.RadicalExtraAscender,
      [63] = mathconstants.RadicalKernBeforeDegree,
      [64] = mathconstants.RadicalKernAfterDegree,
      [65] = mathconstants.RadicalDegreeBottomRaisePercent,
    }
  elseif kind == 'tex2' then
    return param_symbols
  elseif kind == 'tex3' then
    return param_large
  end
  assert(false)
end

local first_free_slot = 0x110000 -- Decide where to remap remaining glyphs. We use the PUA areas for defined mappings

local remap_serif = {
  [0x41] = 0x41, -- A
  [0x42] = 0x42, -- B
  [0x43] = 0x43, -- C
  [0x44] = 0x44, -- D
  [0x45] = 0x45, -- E
  [0x46] = 0x46, -- F
  [0x47] = 0x47, -- G
  [0x48] = 0x48, -- H
  [0x49] = 0x49, -- I
  [0x4A] = 0x4A, -- J
  [0x4B] = 0x4B, -- K
  [0x4C] = 0x4C, -- L
  [0x4D] = 0x4D, -- M
  [0x4E] = 0x4E, -- N
  [0x4F] = 0x4F, -- O
  [0x50] = 0x50, -- P
  [0x51] = 0x51, -- Q
  [0x52] = 0x52, -- R
  [0x53] = 0x53, -- S
  [0x54] = 0x54, -- T
  [0x55] = 0x55, -- U
  [0x56] = 0x56, -- V
  [0x57] = 0x57, -- W
  [0x58] = 0x58, -- X
  [0x59] = 0x59, -- Y
  [0x5A] = 0x5A, -- Z
  [0x61] = 0x61, -- a
  [0x62] = 0x62, -- b
  [0x63] = 0x63, -- c
  [0x64] = 0x64, -- d
  [0x65] = 0x65, -- e
  [0x66] = 0x66, -- f
  [0x67] = 0x67, -- g
  [0x68] = 0x68, -- h
  [0x69] = 0x69, -- i
  [0x6A] = 0x6A, -- j
  [0x6B] = 0x6B, -- k
  [0x6C] = 0x6C, -- l
  [0x6D] = 0x6D, -- m
  [0x6E] = 0x6E, -- n
  [0x6F] = 0x6F, -- o
  [0x70] = 0x70, -- p
  [0x71] = 0x71, -- q
  [0x72] = 0x72, -- r
  [0x73] = 0x73, -- s
  [0x74] = 0x74, -- t
  [0x75] = 0x75, -- u
  [0x76] = 0x76, -- v
  [0x77] = 0x77, -- w
  [0x78] = 0x78, -- x
  [0x79] = 0x79, -- y
  [0x7A] = 0x7A, -- z
}

local remap_sans = {
  [0x41] = 0x1D5A0, -- 𝖠
  [0x42] = 0x1D5A1, -- 𝖡
  [0x43] = 0x1D5A2, -- 𝖢
  [0x44] = 0x1D5A3, -- 𝖣
  [0x45] = 0x1D5A4, -- 𝖤
  [0x46] = 0x1D5A5, -- 𝖥
  [0x47] = 0x1D5A6, -- 𝖦
  [0x48] = 0x1D5A7, -- 𝖧
  [0x49] = 0x1D5A8, -- 𝖨
  [0x4A] = 0x1D5A9, -- 𝖩
  [0x4B] = 0x1D5AA, -- 𝖪
  [0x4C] = 0x1D5AB, -- 𝖫
  [0x4D] = 0x1D5AC, -- 𝖬
  [0x4E] = 0x1D5AD, -- 𝖭
  [0x4F] = 0x1D5AE, -- 𝖮
  [0x50] = 0x1D5AF, -- 𝖯
  [0x51] = 0x1D5B0, -- 𝖰
  [0x52] = 0x1D5B1, -- 𝖱
  [0x53] = 0x1D5B2, -- 𝖲
  [0x54] = 0x1D5B3, -- 𝖳
  [0x55] = 0x1D5B4, -- 𝖴
  [0x56] = 0x1D5B5, -- 𝖵
  [0x57] = 0x1D5B6, -- 𝖶
  [0x58] = 0x1D5B7, -- 𝖷
  [0x59] = 0x1D5B8, -- 𝖸
  [0x5A] = 0x1d5b9, -- 𝖹
  [0x61] = 0x1D5BA, -- 𝖺
  [0x62] = 0x1D5BB, -- 𝖻
  [0x63] = 0x1D5BC, -- 𝖼
  [0x64] = 0x1D5BD, -- 𝖽
  [0x65] = 0x1D5BE, -- 𝖾
  [0x66] = 0x1D5BF, -- 𝖿
  [0x67] = 0x1D5C0, -- 𝗀
  [0x68] = 0x1D5C1, -- 𝗁
  [0x69] = 0x1D5C2, -- 𝗂
  [0x6A] = 0x1D5C3, -- 𝗃
  [0x6B] = 0x1D5C4, -- 𝗄
  [0x6C] = 0x1D5C5, -- 𝗅
  [0x6D] = 0x1D5C6, -- 𝗆
  [0x6E] = 0x1D5C7, -- 𝗇
  [0x6F] = 0x1D5C8, -- 𝗈
  [0x70] = 0x1D5C9, -- 𝗉
  [0x71] = 0x1D5CA, -- 𝗊
  [0x72] = 0x1D5CB, -- 𝗋
  [0x73] = 0x1D5CC, -- 𝗌
  [0x74] = 0x1D5CD, -- 𝗍
  [0x75] = 0x1D5CE, -- 𝗎
  [0x76] = 0x1D5CF, -- 𝗏
  [0x77] = 0x1D5D0, -- 𝗐
  [0x78] = 0x1D5D1, -- 𝗑
  [0x79] = 0x1D5D2, -- 𝗒
  [0x7A] = 0x1D5D3, -- 𝗓
}

local remap_cal_upper = {
  [0x41] = 0x1D49C, -- 𝒜
  [0x42] = 0x212C, -- ℬ
  [0x43] = 0x1D49E, -- 𝒞
  [0x44] = 0x1D49F, -- 𝒟
  [0x45] = 0x2130, -- ℰ
  [0x46] = 0x2131, -- ℱ
  [0x47] = 0x1D4A2, -- 𝒢
  [0x48] = 0x210B, -- ℋ
  [0x49] = 0x2110, -- ℐ
  [0x4A] = 0x1D4A5, -- 𝒥
  [0x4B] = 0x1D4A6, -- 𝒦
  [0x4C] = 0x2112, -- ℒ
  [0x4D] = 0x2133, -- ℳ
  [0x4E] = 0x1D4A9, -- 𝒩
  [0x4F] = 0x1D4AA, -- 𝒪
  [0x50] = 0x1D4AB, -- 𝒫
  [0x51] = 0x1D4AC, -- 𝒬
  [0x52] = 0x211B, -- ℛ
  [0x53] = 0x1D4AE, -- 𝒮
  [0x54] = 0x1D4AF, -- 𝒯
  [0x55] = 0x1D4B0, -- 𝒰
  [0x56] = 0x1D4B1, -- 𝒱
  [0x57] = 0x1D4B2, -- 𝒲
  [0x58] = 0x1D4B3, -- 𝒳
  [0x59] = 0x1D4B4, -- 𝒴
  [0x5A] = 0x1D4B5, -- 𝒵
}

local remap_cal_upper_bold = {
  [0x41] = 0x1D4D0, -- 𝓐
  [0x42] = 0x1D4D1, -- 𝓑
  [0x43] = 0x1D4D2, -- 𝓒
  [0x44] = 0x1D4D3, -- 𝓓
  [0x45] = 0x1D4D4, -- 𝓔
  [0x46] = 0x1D4D5, -- 𝓕
  [0x47] = 0x1D4D6, -- 𝓖
  [0x48] = 0x1D4D7, -- 𝓗
  [0x49] = 0x1D4D8, -- 𝓘
  [0x4A] = 0x1D4D9, -- 𝓙
  [0x4B] = 0x1D4DA, -- 𝓚
  [0x4C] = 0x1D4DB, -- 𝓛
  [0x4D] = 0x1D4DC, -- 𝓜
  [0x4E] = 0x1D4DD, -- 𝓝
  [0x4F] = 0x1D4DE, -- 𝓞
  [0x50] = 0x1D4DF, -- 𝓟
  [0x51] = 0x1D4E0, -- 𝓠
  [0x52] = 0x1D4E1, -- 𝓡
  [0x53] = 0x1D4E2, -- 𝓢
  [0x54] = 0x1D4E3, -- 𝓣
  [0x55] = 0x1D4E4, -- 𝓤
  [0x56] = 0x1D4E5, -- 𝓥
  [0x57] = 0x1D4E6, -- 𝓦
  [0x58] = 0x1D4E7, -- 𝓧
  [0x59] = 0x1D4E8, -- 𝓨
  [0x5A] = 0x1D4E9, -- 𝓩
}

local remap_frak = {
  [0x41] = 0x1D504, -- 𝔄
  [0x42] = 0x1D505, -- 𝔅
  [0x43] = 0x0212D, -- 𝔆
  [0x44] = 0x1D507, -- 𝔇
  [0x45] = 0x1D508, -- 𝔈
  [0x46] = 0x1D509, -- 𝔉
  [0x47] = 0x1D50A, -- 𝔊
  [0x48] = 0x0210C, -- 𝔋
  [0x49] = 0x1D50C, -- 𝔌 -- In Unicode unified with \Im, here it is separate
  [0x4A] = 0x1D50D, -- 𝔍
  [0x4B] = 0x1D50E, -- 𝔎
  [0x4C] = 0x1D50F, -- 𝔏
  [0x4D] = 0x1D510, -- 𝔐
  [0x4E] = 0x1D511, -- 𝔑
  [0x4F] = 0x1D512, -- 𝔒
  [0x50] = 0x1D513, -- 𝔓
  [0x51] = 0x1D514, -- 𝔔
  [0x52] = 0x1D515, -- 𝔕 -- In Unicode unified with \Re, here it is separate
  [0x53] = 0x1D516, -- 𝔖
  [0x54] = 0x1D517, -- 𝔗
  [0x55] = 0x1D518, -- 𝔘
  [0x56] = 0x1D519, -- 𝔙
  [0x57] = 0x1D51A, -- 𝔚
  [0x58] = 0x1D51B, -- 𝔛
  [0x59] = 0x1D51C, -- 𝔜
  [0x5A] = 0x1D51D, -- 𝔝
  [0x61] = 0x1D51E, -- 𝔞
  [0x62] = 0x1D51F, -- 𝔟
  [0x63] = 0x1D520, -- 𝔠
  [0x64] = 0x1D521, -- 𝔡
  [0x65] = 0x1D522, -- 𝔢
  [0x66] = 0x1D523, -- 𝔣
  [0x67] = 0x1D524, -- 𝔤
  [0x68] = 0x1D525, -- 𝔥
  [0x69] = 0x1D526, -- 𝔦
  [0x6A] = 0x1D527, -- 𝔧
  [0x6B] = 0x1D528, -- 𝔨
  [0x6C] = 0x1D529, -- 𝔩
  [0x6D] = 0x1D52A, -- 𝔪
  [0x6E] = 0x1D52B, -- 𝔫
  [0x6F] = 0x1D52C, -- 𝔬
  [0x70] = 0x1D52D, -- 𝔭
  [0x71] = 0x1D52E, -- 𝔮
  [0x72] = 0x1D52F, -- 𝔯
  [0x73] = 0x1D530, -- 𝔰
  [0x74] = 0x1D531, -- 𝔱
  [0x75] = 0x1D532, -- 𝔲
  [0x76] = 0x1D533, -- 𝔳
  [0x77] = 0x1D534, -- 𝔴
  [0x78] = 0x1D535, -- 𝔵
  [0x79] = 0x1D536, -- 𝔶
  [0x7A] = 0x1D537, -- 𝔷
}

local remap_frak_bold = {
  [0x41] = 0x1D56C, -- 𝕬
  [0x42] = 0x1D56D, -- 𝕭
  [0x43] = 0x1D56E, -- 𝕮
  [0x44] = 0x1D56F, -- 𝕯
  [0x45] = 0x1D570, -- 𝕰
  [0x46] = 0x1D571, -- 𝕱
  [0x47] = 0x1D572, -- 𝕲
  [0x48] = 0x1D573, -- 𝕳
  [0x49] = 0x1D574, -- 𝕴
  [0x4A] = 0x1D575, -- 𝕵
  [0x4B] = 0x1D576, -- 𝕶
  [0x4C] = 0x1D577, -- 𝕷
  [0x4D] = 0x1D578, -- 𝕸
  [0x4E] = 0x1D579, -- 𝕹
  [0x4F] = 0x1D57A, -- 𝕺
  [0x50] = 0x1D57B, -- 𝕻
  [0x51] = 0x1D57C, -- 𝕼
  [0x52] = 0x1D57D, -- 𝕽
  [0x53] = 0x1D57E, -- 𝕾
  [0x54] = 0x1D57F, -- 𝕿
  [0x55] = 0x1D580, -- 𝖀
  [0x56] = 0x1D581, -- 𝖁
  [0x57] = 0x1D582, -- 𝖂
  [0x58] = 0x1D583, -- 𝖃
  [0x59] = 0x1D584, -- 𝖄
  [0x5A] = 0x1D585, -- 𝖅
  [0x61] = 0x1D4EA, -- 𝓪
  [0x62] = 0x1D4EB, -- 𝓫
  [0x63] = 0x1D4EC, -- 𝓬
  [0x64] = 0x1D4ED, -- 𝓭
  [0x65] = 0x1D4EE, -- 𝓮
  [0x66] = 0x1D4EF, -- 𝓯
  [0x67] = 0x1D4F0, -- 𝓰
  [0x68] = 0x1D4F1, -- 𝓱
  [0x69] = 0x1D4F2, -- 𝓲
  [0x6A] = 0x1D4F3, -- 𝓳
  [0x6B] = 0x1D4F4, -- 𝓴
  [0x6C] = 0x1D4F5, -- 𝓵
  [0x6D] = 0x1D4F6, -- 𝓶
  [0x6E] = 0x1D4F7, -- 𝓷
  [0x6F] = 0x1D4F8, -- 𝓸
  [0x70] = 0x1D4F9, -- 𝓹
  [0x71] = 0x1D4FA, -- 𝓺
  [0x72] = 0x1D4FB, -- 𝓻
  [0x73] = 0x1D4FC, -- 𝓼
  [0x74] = 0x1D4FD, -- 𝓽
  [0x75] = 0x1D4FE, -- 𝓾
  [0x76] = 0x1D4FF, -- 𝓿
  [0x77] = 0x1D500, -- 𝔀
  [0x78] = 0x1D501, -- 𝔁
  [0x79] = 0x1D502, -- 𝔂
  [0x7A] = 0x1D503, -- 𝔃
}

local remap_bb = {
  [0x41] = 0x1D538, -- 𝔸
  [0x42] = 0x1D539, -- 𝔹
  [0x43] = 0x02102, -- ℂ
  [0x44] = 0x1D53B, -- 𝔻
  [0x45] = 0x1D53C, -- 𝔼
  [0x46] = 0x1D53D, -- 𝔽
  [0x47] = 0x1D53E, -- 𝔾
  [0x48] = 0x0210D, -- ℍ
  [0x49] = 0x1D540, -- 𝕀
  [0x4A] = 0x1D541, -- 𝕁
  [0x4B] = 0x1D542, -- 𝕂
  [0x4C] = 0x1D543, -- 𝕃
  [0x4D] = 0x1D544, -- 𝕄
  [0x4E] = 0x02115, -- ℕ
  [0x4F] = 0x1D546, -- 𝕆
  [0x50] = 0x02119, -- ℙ
  [0x51] = 0x0211A, -- ℚ
  [0x52] = 0x0211D, -- ℝ
  [0x53] = 0x1D54A, -- 𝕊
  [0x54] = 0x1D54B, -- 𝕋
  [0x55] = 0x1D54C, -- 𝕌
  [0x56] = 0x1D54D, -- 𝕍
  [0x57] = 0x1D54E, -- 𝕎
  [0x58] = 0x1D54F, -- 𝕏
  [0x59] = 0x1D550, -- 𝕐
  [0x5A] = 0x02124, -- ℤ

  [0x7C] = 0x1D55C, -- 𝕜
}

local remap_letters = {
  -- Greek italic
  [0x00] = 0x1D6E4, -- 𝛤
  [0x01] = 0x1D6E5, -- 𝛥
  [0x02] = 0x1D6E9, -- 𝛩
  [0x03] = 0x1D6EC, -- 𝛬
  [0x04] = 0x1D6EF, -- 𝛯
  [0x05] = 0x1D6F1, -- 𝛱
  [0x06] = 0x1D6F4, -- 𝛴
  [0x07] = 0x1D6F6, -- 𝛶
  [0x08] = 0x1D6F7, -- 𝛷
  [0x09] = 0x1D6F9, -- 𝛹
  [0x0A] = 0x1D6FA, -- 𝛺
  [0x0B] = 0x1D6FC, -- 𝛼
  [0x0C] = 0x1D6FD, -- 𝛽
  [0x0D] = 0x1D6FE, -- 𝛾
  [0x0E] = 0x1D6FF, -- 𝛿
  [0x0F] = 0x1D716, -- 𝜖
  [0x10] = 0x1D701, -- 𝜁
  [0x11] = 0x1D702, -- 𝜂
  [0x12] = 0x1D703, -- 𝜃
  [0x13] = 0x1D704, -- 𝜄
  [0x14] = 0x1D705, -- 𝜅
  [0x15] = 0x1D706, -- 𝜆
  [0x16] = 0x1D707, -- 𝜇
  [0x17] = 0x1D708, -- 𝜈
  [0x18] = 0x1D709, -- 𝜉
  [0x19] = 0x1D70B, -- 𝜋
  [0x1A] = 0x1D70C, -- 𝜌
  [0x1B] = 0x1D70E, -- 𝜎
  [0x1C] = 0x1D70F, -- 𝜏
  [0x1D] = 0x1D710, -- 𝜐
  [0x1E] = 0x1D719, -- 𝜙
  [0x1F] = 0x1D712, -- 𝜒
  [0x20] = 0x1D713, -- 𝜓
  [0x21] = 0x1D714, -- 𝜔
  [0x22] = 0x1D700, -- 𝜀
  [0x23] = 0x1D717, -- 𝜗
  [0x24] = 0x1D71B, -- 𝜛
  [0x25] = 0x1D71A, -- 𝜚
  [0x26] = 0x1D70D, -- 𝜍
  [0x27] = 0x1D711, -- 𝜑
  -- Symbols. (The nils are hook parts)
  [0x28] = 0x21BC, -- ↼
  [0x29] = 0x21BD, -- ↽
  [0x2A] = 0x21C0, -- ⇀
  [0x2B] = 0x21C1, -- ⇁
  -- [0x2C] = nil,
  -- [0x2D] = nil,
  [0x2E] = 0x28, -- (
  [0x2F] = 0x29, -- )
  -- Digits
  [0x30] = 0x30, -- 0
  [0x31] = 0x31, -- 1
  [0x32] = 0x32, -- 2
  [0x33] = 0x33, -- 3
  [0x34] = 0x34, -- 4
  [0x35] = 0x35, -- 5
  [0x36] = 0x36, -- 6
  [0x37] = 0x37, -- 7
  [0x38] = 0x38, -- 8
  [0x39] = 0x39, -- 9
  [0x3A] = 0x2E, -- .
  [0x3B] = 0x2C, -- ,
  [0x3C] = 0x3C, -- <
  [0x3D] = 0x2F, -- /
  [0x3E] = 0x3E, -- >
  [0x3F] = 0x22C6, -- ⋆
  -- Letters filled up with symbols
  [0x40] = 0x2202, -- ∂
  [0x41] = 0x1D434, -- 𝐴
  [0x42] = 0x1D435, -- 𝐵
  [0x43] = 0x1D436, -- 𝐶
  [0x44] = 0x1D437, -- 𝐷
  [0x45] = 0x1D438, -- 𝐸
  [0x46] = 0x1D439, -- 𝐹
  [0x47] = 0x1D43A, -- 𝐺
  [0x48] = 0x1D43B, -- 𝐻
  [0x49] = 0x1D43C, -- 𝐼
  [0x4A] = 0x1D43D, -- 𝐽
  [0x4B] = 0x1D43E, -- 𝐾
  [0x4C] = 0x1D43F, -- 𝐿
  [0x4D] = 0x1D440, -- 𝑀
  [0x4E] = 0x1D441, -- 𝑁
  [0x4F] = 0x1D442, -- 𝑂
  [0x50] = 0x1D443, -- 𝑃
  [0x51] = 0x1D444, -- 𝑄
  [0x52] = 0x1D445, -- 𝑅
  [0x53] = 0x1D446, -- 𝑆
  [0x54] = 0x1D447, -- 𝑇
  [0x55] = 0x1D448, -- 𝑈
  [0x56] = 0x1D449, -- 𝑉
  [0x57] = 0x1D44A, -- 𝑊
  [0x58] = 0x1D44B, -- 𝑋
  [0x59] = 0x1D44C, -- 𝑌
  [0x5A] = 0x1D44D, -- 𝑍
  [0x5B] = 0x266D, -- ♭
  [0x5C] = 0x266E, -- ♮
  [0x5D] = 0x266F, -- ♯
  [0x5E] = 0x2323, -- ⌣
  [0x5F] = 0x2322, -- ⌢
  [0x60] = 0x2113, -- ℓ
  [0x61] = 0x1D44E, -- 𝑎
  [0x62] = 0x1D44F, -- 𝑏
  [0x63] = 0x1D450, -- 𝑐
  [0x64] = 0x1D451, -- 𝑑
  [0x65] = 0x1D452, -- 𝑒
  [0x66] = 0x1D453, -- 𝑓
  [0x67] = 0x1D454, -- 𝑔
  [0x68] = 0x210E, -- ℎ
  [0x69] = 0x1D456, -- 𝑖
  [0x6A] = 0x1D457, -- 𝑗
  [0x6B] = 0x1D458, -- 𝑘
  [0x6C] = 0x1D459, -- 𝑙
  [0x6D] = 0x1D45A, -- 𝑚
  [0x6E] = 0x1D45B, -- 𝑛
  [0x6F] = 0x1D45C, -- 𝑜
  [0x70] = 0x1D45D, -- 𝑝
  [0x71] = 0x1D45E, -- 𝑞
  [0x72] = 0x1D45F, -- 𝑟
  [0x73] = 0x1D460, -- 𝑠
  [0x74] = 0x1D461, -- 𝑡
  [0x75] = 0x1D462, -- 𝑢
  [0x76] = 0x1D463, -- 𝑣
  [0x77] = 0x1D464, -- 𝑤
  [0x78] = 0x1D465, -- 𝑥
  [0x79] = 0x1D466, -- 𝑦
  [0x7A] = 0x1D467, -- 𝑧
  [0x7B] = 0x1D6A4, -- 𝚤
  [0x7C] = 0x1D6A5, -- 𝚥
  [0x7D] = 0x2118, -- ℘
  [0x7E] = 0x1D718, -- 𝜘
  -- Upright greek capitals
  [0x7F] = 0x03A9, -- Ω
  [0x80] = 0x0393, -- Γ
  [0x81] = 0x0394, -- Δ
  [0x82] = 0x0398, -- Θ
  [0x83] = 0x039B, -- Λ
  [0x84] = 0x039E, -- Ξ
  [0x85] = 0x03A0, -- Π
  [0x86] = 0x03A3, -- Σ
  [0x87] = 0x03A5, -- Υ
  [0x88] = 0x03A6, -- Φ
  [0x89] = 0x03A8, -- Ψ
  --
  [0x8A] = 0x21, -- !
  [0x8B] = 0x3F, -- ?
  --
  [0x8C] = 0x5B, -- [
  [0x8D] = 0x5D, -- ]
  [0x8E] = 0x2020, -- †
  [0x8F] = 0x2021, -- ‡
  [0x90] = 0xA7, -- §
  [0x91] = 0xB6, -- ¶
  -- Upright greek lowercase
  [0x92] = 0x03B1, -- α
  [0x93] = 0x03B2, -- β
  [0x94] = 0x03B3, -- γ
  [0x95] = 0x03B4, -- δ
  [0x96] = 0x03F5, -- ϵ
  [0x97] = 0x03B6, -- ζ
  [0x98] = 0x03B7, -- η
  [0x99] = 0x03B8, -- θ
  [0x9A] = 0x03B9, -- ι
  [0x9B] = 0x03BA, -- κ
  [0x9C] = 0x03BB, -- λ
  [0x9D] = 0x03BC, -- μ
  [0x9E] = 0x03BD, -- ν
  [0x9F] = 0x03BE, -- ξ
  [0xA0] = 0x03C0, -- π
  [0xA1] = 0x03C1, -- ρ
  [0xA2] = 0x03C3, -- σ
  [0xA3] = 0x03C4, -- τ
  [0xA4] = 0x03C5, -- υ
  [0xA5] = 0x03D5, -- ϕ
  [0xA6] = 0x03C7, -- χ
  [0xA7] = 0x03C8, -- ψ
  [0xA8] = 0x03C9, -- ω
  [0xA9] = 0x03B5, -- ε
  [0xAA] = 0x03D1, -- ϑ
  [0xAB] = 0x03D6, -- ϖ
  [0xAC] = 0x03F1, -- ϱ
  [0xAD] = 0x03C2, -- ς
  [0xAE] = 0x03C6, -- φ
  [0xAF] = 0x03F0, -- ϰ
  -- [0xB0] = \varbeta
  [0xB1] = 0x03D0, -- ϐ -- upright \varbeta
  [0xB2] = 0x1D715, -- 𝜕 -- \vardelta (slightly more slanted \partial)
  -- [0xB3] = upright \vardelta (upright \partial)
  -- [0xB4] = variant of z
  -- [0xB5] = italic variant of đ
  [0xB6] = 0x0111, -- đ
}

-- These are some additional glyphs here which do not have bold variants in Unicode,
-- especially dotless i, dotless j, period and some accents
local remap_bold = {
  [0x30] = 0x1D7CE, -- 𝟎
  [0x31] = 0x1D7CF, -- 𝟏
  [0x32] = 0x1D7D0, -- 𝟐
  [0x33] = 0x1D7D1, -- 𝟑
  [0x34] = 0x1D7D2, -- 𝟒
  [0x35] = 0x1D7D3, -- 𝟓
  [0x36] = 0x1D7D4, -- 𝟔
  [0x37] = 0x1D7D5, -- 𝟕
  [0x38] = 0x1D7D6, -- 𝟖
  [0x39] = 0x1D7D7, -- 𝟗
  [0x41] = 0x1D400, -- 𝐀
  [0x42] = 0x1D401, -- 𝐁
  [0x43] = 0x1D402, -- 𝐂
  [0x44] = 0x1D403, -- 𝐃
  [0x45] = 0x1D404, -- 𝐄
  [0x46] = 0x1D405, -- 𝐅
  [0x47] = 0x1D406, -- 𝐆
  [0x48] = 0x1D407, -- 𝐇
  [0x49] = 0x1D408, -- 𝐈
  [0x4A] = 0x1D409, -- 𝐉
  [0x4B] = 0x1D40A, -- 𝐊
  [0x4C] = 0x1D40B, -- 𝐋
  [0x4D] = 0x1D40C, -- 𝐌
  [0x4E] = 0x1D40D, -- 𝐍
  [0x4F] = 0x1D40E, -- 𝐎
  [0x50] = 0x1D40F, -- 𝐏
  [0x51] = 0x1D410, -- 𝐐
  [0x52] = 0x1D411, -- 𝐑
  [0x53] = 0x1D412, -- 𝐒
  [0x54] = 0x1D413, -- 𝐓
  [0x55] = 0x1D414, -- 𝐔
  [0x56] = 0x1D415, -- 𝐕
  [0x57] = 0x1D416, -- 𝐖
  [0x58] = 0x1D417, -- 𝐗
  [0x59] = 0x1D418, -- 𝐘
  [0x5A] = 0x1D419, -- 𝐙
  [0x61] = 0x1D41A, -- 𝐚
  [0x62] = 0x1D41B, -- 𝐛
  [0x63] = 0x1D41C, -- 𝐜
  [0x64] = 0x1D41D, -- 𝐝
  [0x65] = 0x1D41E, -- 𝐞
  [0x66] = 0x1D41F, -- 𝐟
  [0x67] = 0x1D420, -- 𝐠
  [0x68] = 0x1D421, -- 𝐡
  [0x69] = 0x1D422, -- 𝐢
  [0x6A] = 0x1D423, -- 𝐣
  [0x6B] = 0x1D424, -- 𝐤
  [0x6C] = 0x1D425, -- 𝐥
  [0x6D] = 0x1D426, -- 𝐦
  [0x6E] = 0x1D427, -- 𝐧
  [0x6F] = 0x1D428, -- 𝐨
  [0x70] = 0x1D429, -- 𝐩
  [0x71] = 0x1D42A, -- 𝐪
  [0x72] = 0x1D42B, -- 𝐫
  [0x73] = 0x1D42C, -- 𝐬
  [0x74] = 0x1D42D, -- 𝐭
  [0x75] = 0x1D42E, -- 𝐮
  [0x76] = 0x1D42F, -- 𝐯
  [0x77] = 0x1D430, -- 𝐰
  [0x78] = 0x1D431, -- 𝐱
  [0x79] = 0x1D432, -- 𝐲
  [0x7A] = 0x1D433, -- 𝐳
}

-- \DeclareMathSymbol{\bigcupprod}{\mathop}{largesymbols}{"8E}
-- \DeclareMathSymbol{\bigcapprod}{\mathop}{largesymbols}{"90}
-- \DeclareMathSymbol{\bigvarland}{\mathop}{largesymbols}{"A6}
-- \DeclareMathSymbol{\bigast}{\mathop}{largesymbols}{"A8}
-- \DeclareMathAccent{\wwhat}  {\mathord}{largesymbols}{"80}
-- \DeclareMathAccent{\wwtilde}{\mathord}{largesymbols}{"81}
-- \DeclareMathAccent{\wwcheck}{\mathord}{largesymbols}{"7D}
local remap_symbols = {
  [0x00] = 0x2212, -- −
  [0x01] = 0x22C5, -- ⋅
  [0x02] = 0xD7, -- ×
  [0x03] = 0x2217, -- *
  [0x04] = 0xF7, -- ÷
  [0x05] = 0x22C4, -- ⋄
  [0x06] = 0xB1, -- ±
  [0x07] = 0x2213, -- ∓
  [0x08] = 0x2295, -- ⊕
  [0x09] = 0x2296, -- ⊖
  [0x0A] = 0x2297, -- ⊗
  [0x0B] = 0x2298, -- ⊘
  [0x0C] = 0x2299, -- ⊙
  [0x0D] = 0x25EF, -- ◯
  [0x0E] = 0x25E6, -- ◦
  [0x0F] = 0x2219, -- ∙
  [0x10] = 0x224D, -- ≍
  [0x11] = 0x2261, -- ≡
  [0x12] = 0x2286, -- ⊆
  [0x13] = 0x2287, -- ⊇
  [0x14] = 0x2264, -- ≤
  [0x15] = 0x2265, -- ≥
  [0x16] = 0x2AAF, -- ⪯
  [0x17] = 0x2AB0, -- ⪰
  [0x18] = 0x223C, -- ∼
  [0x19] = 0x2248, -- ≈
  [0x1A] = 0x2282, -- ⊂
  [0x1B] = 0x2283, -- ⊃
  [0x1C] = 0x226A, -- ≪
  [0x1D] = 0x226B, -- ≫
  [0x1E] = 0x227A, -- ≺
  [0x1F] = 0x227B, -- ≻
  [0x20] = 0x2190, -- ←
  [0x21] = 0x2192, -- →
  [0x22] = 0x2191, -- ↑
  [0x23] = 0x2193, -- ↓
  [0x24] = 0x2194, -- ↔
  [0x25] = 0x2197, -- ↗
  [0x26] = 0x2198, -- ↘
  [0x27] = 0x2243, -- ≃
  [0x28] = 0x21D0, -- ⇐
  [0x29] = 0x21D2, -- ⇒
  [0x2A] = 0x21D1, -- ⇑
  [0x2B] = 0x21D3, -- ⇓
  [0x2C] = 0x21D4, -- ⇔
  [0x2D] = 0x2196, -- ↖
  [0x2E] = 0x2199, -- ↙
  [0x2F] = 0x221D, -- ∝
  [0x30] = 0x2032, -- ′
  [0x31] = 0x221E, -- ∞
  [0x32] = 0x2208, -- ∈
  [0x33] = 0x220B, -- ∋
  [0x34] = 0x25B3, -- △
  [0x35] = 0x25BD, -- ▽
  [0x36] = 0x0338, -- ̸
  -- [0x37] = 0x21A6, -- \mapstochar -- component
  [0x38] = 0x2200, -- ∀
  [0x39] = 0x2203, -- ∃
  [0x3A] = 0xAC, -- ¬
  [0x3B] = 0x2205, -- ∅
  [0x3C] = 0x211C, -- ℜ
  [0x3D] = 0x2111, -- ℑ
  [0x3E] = 0x22A4, -- ⊤
  [0x3F] = 0x22A5, -- ⊥
  [0x40] = 0x2135, -- ℵ
  [0x41] = 0x2040, -- This is a *text* tie accent?! Mapped as binary operator (?!?) consisten with XCharter Math
  [0x42] = 0x2218, -- ∘
  [0x43] = 0x2B, -- +
  [0x44] = 0x3D, -- =
  [0x45] = 0x20D7, -- \vec
  [0x46] = 0x25B7, -- \triangleright
  [0x47] = 0x25C1, -- \triangleleft
  -- [0x48] = 0xFind_unicode('Relbar') -- \Relbar -- component -- Maybe not needed since precomposed character exist --> Check
  [0x49] = 0x3B, -- ;
  [0x4A] = 0x0300, -- \grave
  [0x4B] = 0x0301, -- \acute
  [0x4C] = 0x030C, -- \check
  [0x4D] = 0x0306, -- \breve
  [0x4E] = 0x0304, -- \bar
  [0x4F] = 0x0302, -- \hat
  [0x50] = 0x0307, -- \dot
  [0x51] = 0x0303, -- \tilde
  [0x52] = 0x0308, -- \ddot
  -- [0x53] = 0xFind_unicode('wwbar') -- \wwbar -- next for 0x78
  -- [0x54] = 0xFind_unicode('dotup') -- \dotup -- Slightly higher version of \dot!?
  -- [0x55] = 0xFind_unicode('ddotup') -- \ddotup -- Slightly higher version of \ddot!?
  [0x56] = 0x030A, -- \mathring
  [0x57] = 0x3A, -- :
  -- Small versions of symbold for set operations
  [0x58] = 0x2216,
  -- [0x59] = 0xFind_unicode('cupprod') -- \cupprod
  -- [0x5A] = 0xFind_unicode('capprod') -- \capprod
  [0x5B] = 0x222A, -- ∪
  [0x5C] = 0x2229, -- ∩
  [0x5D] = 0x228E, -- ⊎
  [0x5E] = 0x2227, -- ∧
  [0x5F] = 0x2228, -- ∨
  [0x60] = 0x22A2, -- ⊢
  [0x61] = 0x22A3, -- ⊣
  [0x62] = 0x230A, -- ⌊
  [0x63] = 0x230B, -- ⌋
  [0x64] = 0x2308, -- ⌈
  [0x65] = 0x2309, -- ⌉
  [0x66] = 0x7B, -- {
  [0x67] = 0x7D, -- }
  [0x68] = 0x27E8, -- ⟨
  [0x69] = 0x27E9, -- ⟩
  [0x6A] = 0x7C, -- |
  [0x6B] = 0x2016, -- ‖
  [0x6C] = 0x2195, -- ↕
  [0x6D] = 0x21D5, -- ⇕
  [0x6E] = 0x5C, -- \
  [0x6F] = 0x2240, -- ≀
  [0x70] = 0x221A, -- √
  [0x71] = 0x2A3F, -- ⨿
  [0x72] = 0x2207, -- ∇
  [0x73] = 0x222B, -- ∫
  [0x74] = 0x2294, -- ⊔
  [0x75] = 0x2293, -- ⊓
  [0x76] = 0x2291, -- ⊑
  [0x77] = 0x2292, -- ⊒
  -- [0x78] = 0xFind_unicode('wbar') -- \wbar -- next for 0x4E
  -- [0x79] = 0xFind_unicode('what') -- \what -- next for 0x4F
  -- [0x7A] = 0xFind_unicode('wtilde') -- \wtilde -- next for 0x51
  -- [0x7B] = 0xFind_unicode('wcheck') -- \wcheck -- next for 0x4C
  [0x7C] = 0x2663, -- \clubsuit
  [0x7D] = 0x2662, -- \diamondsuit
  [0x7E] = 0x2661, -- \heartsuit
  [0x7F] = 0x2660, -- \spadesuit
  -- mtpro2 has shaded versions of the dark suits instead of dark versions of the light ones.
  -- You could get the impression that someone has a preference.
  [0x80] = 0x2667, -- \openclubsuit
  -- [0x81] = 0xFind_unicode('shadedclubsuit') -- \shadedclubsuit
  [0x82] = 0x2664, -- \openspadesuit
  -- [0x83] = 0xFind_unicode('shadedspadesuit') -- \shadedspadesuit
  -- [0x84] = 0xFind_unicode('hbar') -- \hbar -- variant of \hslash
  [0x85] = 0x2209, -- \notin
  [0x86] = 0x2220, -- \angle
  [0x87] = 0x2250, -- \doteq
  [0x88] = 0x22A7, -- \models
  [0x89] = 0x22C8, -- \bowtie
  [0x8A] = 0x2245, -- \cong
  [0x8B] = 0x21A9, -- \hookleftarrow
  [0x8C] = 0x21AA, -- \hookrightarrow
  [0x8D] = 0x27F5, -- \longleftarrow
  [0x8E] = 0x27F6, -- \longrightarrow
  [0x8F] = 0x27F8, -- \Longleftarrow
  [0x90] = 0x27F9, -- \Longrightarrow
  [0x91] = 0x21A6, -- \mapsto
  [0x92] = 0x27FC, -- \longmapsto
  [0x93] = 0x27F7, -- \longleftrightarrow
  [0x94] = 0x27FA, -- \Longleftrightarrow
  [0x95] = 0x21CC, -- \rightleftharpoons
  [0x96] = 0x226F, -- \notless
  [0x97] = 0x2270, -- \notleq
  [0x98] = 0x2280, -- \notprec
  [0x99] = 0x22E0, -- \notpreceq
  [0x9A] = 0x2284, -- \notsubset
  [0x9B] = 0x2288, -- \notsubseteq
  [0x9C] = 0x22E2, -- \notsqsubseteq
  [0x9D] = 0x226F, -- \notgr
  [0x9E] = 0x2271, -- \notgeq
  [0x9F] = 0x2281, -- \notsucc
  [0xA0] = 0x22E1, -- \notsucceq
  [0xA1] = 0x2285, -- \notsupset
  [0xA2] = 0x2289, -- \notsupseteq
  [0xA3] = 0x22E3, -- \notsqsupseteq
  [0xA4] = 0x2260, -- \neq
  [0xA5] = 0x2262, -- \notequiv
  [0xA6] = 0x2241, -- \notsim
  [0xA7] = 0x2244, -- \notsimeq
  [0xA8] = 0x2249, -- \notapprox
  [0xA9] = 0x2247, -- \notcong
  [0xAA] = 0x226D, -- \notasymp
  [0xAB] = 0x20DB, -- \dddot
  [0xAC] = 0x20DC, -- \ddddot
  -- [0xAD] = 0xFind_unicode('dddotup') -- \dddotup  -- Slightly higher version of \dddot!?
  -- [0xAE] = 0xFind_unicode('ddddotup') -- \ddddotup  -- Slightly higher version of \ddddot!?
  [0xAF] = 0x210F, -- \hslash
  [0xB0] = 0x2972, -- \simarrow
  [0xB1] = 0x03DC, -- \digamma
  [0xB2] = 0x26, -- \varland
  [0xB3] = 0x231F, -- \contraction -- Mapped to \lrcorner. Feel free to villify me for this choice.
  [0xB4] = 0x2254, -- \coloneq
  [0xB5] = 0x2255, -- \eqcolon
  [0xB6] = 0x2259, -- \hateq
  [0xB7] = 0x22B6, -- \circdashbullet
  [0xB8] = 0x22B7, -- \bulletdashcirc
  -- [0xB9] = -- streight version of \lbrace
  -- [0xBA] = -- streight version of \rbrace
}

local remap_largesymbols_up = {
  -- TODO: Map additional characters
  [0x30] = 0x239B, -- ⎛
  [0x31] = 0x239E, -- ⎞
  [0x32] = 0x23A1, -- ⎡
  [0x33] = 0x23A4, -- ⎤
  [0x34] = 0x23A3, -- ⎣
  [0x35] = 0x23A6, -- ⎦
  [0x36] = 0x23A2, -- ⎢
  [0x37] = 0x23A5, -- ⎥
  [0x38] = 0x23A7, -- ⎧
  [0x39] = 0x23AB, -- ⎫
  [0x3A] = 0x23A9, -- ⎩
  [0x3A] = 0x27EE, -- ⟮
  [0x3B] = 0x23AD, -- ⎭
  [0x3B] = 0x27EF, -- ⟯
  [0x3C] = 0x23A8, -- ⎨
  [0x3D] = 0x23AC, -- ⎬
  [0x3E] = 0x23AE, -- ⎮
  [0x40] = 0x239D, -- ⎝
  [0x41] = 0x23A0, -- ⎠
  [0x42] = 0x239C, -- ⎜
  [0x43] = 0x239F, -- ⎟
  [0x46] = 0x2A06, -- ⨆
  [0x48] = 0x222E, -- ∮
  [0x4A] = 0x2A00, -- ⨀
  [0x4C] = 0x2A01, -- ⨁
  [0x4E] = 0x2A02, -- ⨂
  [0x50] = 0x2211, -- ∑
  [0x51] = 0x220F, -- ∏
  [0x52] = 0x222B, -- ∫
  [0x53] = 0x22C3, -- ⋃
  [0x54] = 0x22C2, -- ⋂
  [0x55] = 0x2A04, -- ⨄
  [0x56] = 0x22C0, -- ⋀
  [0x57] = 0x22C1, -- ⋁
  [0x60] = 0x2210, -- ∐
  [0x74] = 0x23B7, -- ⎷
  [0x88] = 0x23AA, -- ⎪
  [0x92] = 0x222C, -- ∬
  [0x94] = 0x222D, -- ∭
  [0x96] = 0x222F, -- ∯
  [0x98] = 0x2230, -- ∰
  [0x9A] = 0x2232, -- ∲
  [0x9C] = 0x2233, -- ∳
  [0x9E] = 0x2231, -- ∱
  [0xAA] = 0x2A0D, -- ⨍
  [0xAC] = 0x2A0F, -- ⨏
  [0xC3] = 0x23DC, -- ⏜
}

local mappings_larger = {remap_largesymbols_up}

local function cross_family_extensions(characters)
  characters[remap_letters[0x2E]].next = remap_largesymbols_up[0x00]
  characters[remap_letters[0x2F]].next = remap_largesymbols_up[0x01]
  characters[remap_letters[0x3D]].next = remap_largesymbols_up[0x0E]
  characters[remap_letters[0x8C]].next = remap_largesymbols_up[0x02]
  characters[remap_letters[0x8D]].next = remap_largesymbols_up[0x03]

  characters[remap_symbols[0x22]].next = remap_largesymbols_up[0x78]
  characters[remap_symbols[0x23]].next = remap_largesymbols_up[0x79]
  characters[remap_symbols[0x2A]].next = remap_largesymbols_up[0x7E]
  characters[remap_symbols[0x2B]].next = remap_largesymbols_up[0x7F]
  characters[remap_symbols[0x62]].next = remap_largesymbols_up[0x04]
  characters[remap_symbols[0x63]].next = remap_largesymbols_up[0x05]
  characters[remap_symbols[0x64]].next = remap_largesymbols_up[0x06]
  characters[remap_symbols[0x65]].next = remap_largesymbols_up[0x07]
  characters[remap_symbols[0x66]].next = remap_largesymbols_up[0x08]
  characters[remap_symbols[0x67]].next = remap_largesymbols_up[0x09]
  characters[remap_symbols[0x68]].next = remap_largesymbols_up[0x0A]
  characters[remap_symbols[0x69]].next = remap_largesymbols_up[0x0B]
  characters[remap_symbols[0x6A]].next = remap_largesymbols_up[0x0C]
  characters[remap_symbols[0x6B]].next = remap_largesymbols_up[0x0D]
  characters[remap_symbols[0x6C]].next = remap_largesymbols_up[0x3F]
  characters[remap_symbols[0x6D]].next = remap_largesymbols_up[0x77]
  characters[remap_symbols[0x6E]].next = remap_largesymbols_up[0x0F]

  characters[remap_symbols[0x79]].next = remap_largesymbols_up[0x62]
  characters[remap_symbols[0x7A]].next = remap_largesymbols_up[0x65]
  characters[remap_symbols[0x7B]].next = remap_largesymbols_up[0x7A]
  characters[remap_symbols[0x70]].next = remap_largesymbols_up[0x70]
end

local function map_remaining_chars(characters, mapping)
  for i=0x00, 0xFF do
    if characters[i] and not mapping[i] then
      mapping[i] = first_free_slot
      first_free_slot = first_free_slot + 1
    end
  end
end

-- Only for development
local handled = {
  width = true,
  height = true,
  depth = true,
  italic = true,
  kerns = true,
  next = true,
  vert_variants = true,
  ligatures = true, -- FIXME: This is a lie. Only needed for text fonts right now
  commands = true, -- Can be ignored since we use the original font
}

local function copy_char(char, findex, cid, mapping)
  for k, v in next, char do
    if not handled[k] then
      error(string.format('Please handle %s', k))
    end
  end

  local vert_variants
  if char.vert_variants then
    vert_variants = {}
    for i, part in ipairs(char.vert_variants) do
      vert_variants[i] = {
        glyph = mapping[part.glyph],
        extender = part.extender,
        start = part.start,
        ['end'] = part['end'],
        advance = part.advance,
      }
    end
  end

  local kerns
  if char.kerns then
    kerns = {}
    for other, amount in next, char.kerns do
      local mapped = mapping[other]
      if mapped then
        kerns[mapped] = amount
      end
    end
  end

  return {
    width = char.width,
    height = char.height,
    depth = char.depth,
    italic = char.italic,
    kerns = kerns,
    commands = {
      {'slot', findex, cid},
    },
    next = char.next and mapping[char.next],
    vert_variants = vert_variants,
  }
end

local function read_maybe_virtual(name, size)
  local f = font.read_tfm(name, size)
  if not f then return end
  local v = font.read_vf(name, size)
  if not v then return f end
  f.type = 'virtual'
  f.fonts = v.fonts
  for cid, cdata in next, v.characters do
    f.characters[cid].commands = cdata.commands
  end
  return f
end

local function load_font(name, size, mapping, fonts, characters)
  local tfmdata = assert(read_maybe_virtual(name, size))
  local fid = font.define(tfmdata)
  local findex = #fonts + 1
  fonts[findex] = {id = fid}

  map_remaining_chars(tfmdata.characters, mapping)

  for from, to in next, mapping do
    local char = tfmdata.characters[from]
    if char then
      characters[to] = copy_char(char, findex, from, mapping)
    end
  end
  return tfmdata.parameters, tfmdata.characters
end

local function load_serif(size, fonts, characters)
  -- TODO: Make configurable
  local parameters = load_font('ptmr8t', size, remap_serif, fonts, characters)
  -- Greek aliases. No indirection through the remap table since it would be the same and it's a foreign font
  characters[0x0391] = characters[0x41]
  characters[0x0392] = characters[0x42]
  characters[0x0395] = characters[0x45]
  characters[0x0396] = characters[0x5A]
  characters[0x0397] = characters[0x48]
  characters[0x0399] = characters[0x49]
  characters[0x039A] = characters[0x4B]
  characters[0x039C] = characters[0x4D]
  characters[0x039D] = characters[0x4E]
  characters[0x039F] = characters[0x4F]
  characters[0x03A1] = characters[0x50]
  characters[0x03A4] = characters[0x54]
  characters[0x03A7] = characters[0x58]

  characters[0x03BF] = characters[0x6F]
  return parameters
end

local function load_sans(size, fonts, characters)
  -- TODO: Make configurable
  local parameters = load_font('phvr8t', size, remap_sans, fonts, characters)
  return parameters
end

local function load_cal_cm(size, fonts, characters, ssty)
  load_font(({'cmsy7', 'cmsy5'})[ssty] or 'cmsy10', size, remap_cal_upper, fonts, characters)
  load_font(({'cmbsy7', 'cmbsy5'})[ssty] or 'cmbsy10', size, remap_cal_upper_bold, fonts, characters)
end

local function load_cal_euler(size, fonts, characters, ssty)
  load_font(({'eusm5', 'eusm5'})[ssty] or 'eusm10', size, remap_cal_upper, fonts, characters)
  load_font(({'eusb7', 'eusb5'})[ssty] or 'eusb10', size, remap_cal_upper_bold, fonts, characters)
end

local function load_cal(name, ...)
  if name == 'euler' then
    return load_cal_euler(...)
  elseif name == 'cm' then
    return load_cal_cm(...)
  end
end

local function load_frak_euler(size, fonts, characters, ssty)
  load_font(({'eufm5', 'eufm5'})[ssty] or 'eufm10', size, remap_frak, fonts, characters)
  load_font(({'eufb7', 'eufb5'})[ssty] or 'eufb10', size, remap_frak_bold, fonts, characters)
end

local function load_frak(name, ...)
  if name == 'euler' then
    return load_frak_euler(...)
  end
end

local function load_bb(size, fonts, characters, ssty)
  load_font(({'msbm7', 'msbm5'})[ssty] or 'msbm10', size, remap_bb, fonts, characters)
end

local function load_letters(size, fonts, characters, ssty)
  local parameters = load_font(({'mt2mis', 'mt2mif'})[ssty] or 'mt2mit', size, remap_letters, fonts, characters)

  local dot = characters[remap_letters[0x3A]]
  if dot then
    -- Various contractions featuring dots
    -- \ldots
    local thinmuskip = {'right', ssty and 0 or size / 6}
    local dotcmd = {'slot', 0, remap_letters[0x3A]}
    characters[0x2026] = {
      width = 3 * dot.width + (ssty and 0 or size / 3),
      height = dot.height,
      depth = dot.depth,
      italic = dot.italic,
      commands = {
        dotcmd,
        thinmuskip,
        dotcmd,
        thinmuskip,
        dotcmd,
      },
    }
    -- \vdots
    local vmove = {'down', -2 * size / 5}
    local push = {'push'}
    local pop = {'pop'}
    characters[0x22EE] = {
      width = dot.width,
      height = dot.height + 7 * size / 5, -- These are the two offsets and 0.3em random additional height
      depth = dot.depth,
      italic = dot.italic,
      commands = {
        push,
        dotcmd,
        pop,
        vmove,
        push,
        dotcmd,
        pop,
        vmove,
        dotcmd,
      },
    }
    -- \ddots
    local vup = {'down', -7 * size / 10}
    local right_mu = {'right', size / 18}
    local right_2mu = {'right', size / 9}
    local vmove_down = {'down', 3 * size / 10}
    characters[0x22F1] = {
      width = 3 * dot.width + (ssty and 0 or size / 3),
      height = dot.height + 7 * size / 5, -- These are the two offsets and 0.3em random additional height
      depth = dot.depth,
      italic = dot.italic,
      commands = {
        vup,
        right_mu,
        dotcmd,
        vmove_down,
        right_2mu,
        dotcmd,
        vmove_down,
        right_2mu,
        dotcmd,
      },
    }
  end

  characters[0x1D6E2] = characters[remap_letters[0x41]]
  characters[0x1D6E3] = characters[remap_letters[0x42]]
  characters[0x1D6E6] = characters[remap_letters[0x45]]
  characters[0x1D6E7] = characters[remap_letters[0x5A]]
  characters[0x1D6E8] = characters[remap_letters[0x48]]
  characters[0x1D6EA] = characters[remap_letters[0x49]]
  characters[0x1D6EB] = characters[remap_letters[0x4B]]
  characters[0x1D6ED] = characters[remap_letters[0x4D]]
  characters[0x1D6EE] = characters[remap_letters[0x4E]]
  characters[0x1D6F0] = characters[remap_letters[0x4F]]
  characters[0x1D6F2] = characters[remap_letters[0x50]]
  characters[0x1D6F5] = characters[remap_letters[0x54]]
  characters[0x1D6F8] = characters[remap_letters[0x58]]

  characters[0x1D70A] = characters[remap_letters[0x6F]]
  return parameters
end

local function load_bold(size, fonts, characters, ssty)
  local parameters = load_font(({'mt2mbs', 'mt2mbf'})[ssty] or 'mt2mbt', size, remap_bold, fonts, characters)

  return parameters
end

local function load_symbols(size, fonts, characters, ssty)
  local parameters = load_font(({'mt2sys', 'mt2syf'})[ssty] or 'mt2syt', size, remap_symbols, fonts, characters)

  characters[0xB7] = characters[remap_symbols[0x01]] -- Alias, once as binary symbol and once as punctuation
  characters[0x29F5] = characters[remap_symbols[0x6E]] -- Alias, once as binary symbol and once as ordinary
  characters[0x2223] = characters[remap_symbols[0x6A]] -- Alias, once as binary symbol and once as ordinary
  characters[0x2225] = characters[remap_symbols[0x6B]] -- Alias, once as binary symbol and once as ordinary
  characters[0x27C2] = characters[remap_symbols[0x3F]] -- Alias, once as binary symbol and once as ordinary
  characters[remap_symbols[0x4C]].next = remap_symbols[0x7B] -- \wcheck
  characters[remap_symbols[0x4E]].next = remap_symbols[0x78] -- \wbar
  characters[remap_symbols[0x4F]].next = remap_symbols[0x79] -- \what
  characters[remap_symbols[0x51]].next = remap_symbols[0x7A] -- \wtilde
  characters[remap_symbols[0x78]].next = remap_symbols[0x53] -- \wwbar

  return parameters
end

local function load_largesymbols(size, fonts, characters)
  local parameters = load_font('mt2exa', size, remap_largesymbols_up, fonts, characters)

  characters[remap_largesymbols_up[0xC3]].next = remap_largesymbols_up[0xBE] -- \Arc
  characters[remap_largesymbols_up[0xBE]].next = remap_largesymbols_up[0xBF] -- \widearc

  return parameters
end

local function load_xl(size, fonts, characters)
  local mapping_xl, mapping_xxxl = mappings_larger[2], mappings_larger[4]
  if not mapping_xl then
    mapping_xl = {}
    mappings_larger[2] = mapping_xl
  end
  load_font('mt2xl', size, mapping_xl, fonts, characters)
  if not mapping_xxxl then
    mapping_xxxl = {}
    mappings_larger[4] = mapping_xxxl
  end
  load_font('mt2xxxl', 2*size, mapping_xxxl, fonts, characters)

  local function remap(gid, offset_1, offset_2_i, offset_2_ii, offset_3_i, offset_3_ii)
    offset_2_i = offset_2_i or offset_1
    offset_3_i = offset_3_i or offset_2_i
    offset_3_ii = offset_3_ii or offset_2_ii

    local base_glyph = assert(remap_largesymbols_up[gid])
    local char = assert(characters[base_glyph])
    assert(char.next == nil)
    char.next = mapping_xl[offset_1 + 96]

    char = assert(characters[char.next])
    assert(char.next == nil)
    char.next = mapping_xl[offset_1]

    char = assert(characters[char.next])
    assert(char.next == nil)
    if offset_2_ii then
      -- error'TODO'
    else
      char.next = mapping_xl[offset_2_i + 48]
      char = assert(characters[char.next])
      assert(char.next == nil)
    end

    if offset_3_ii then
      -- error'TODO'
    else
      char.next = mapping_xxxl[offset_3_i]
    end
  end
  -- \xl from 96 to 125
  -- \XL from 0 to 29 (same order)
  -- \XXL from 48 to 79 Different order, sometimes two
  -- \XXXL from 0 to 32, different font, different order, sometimes two
  remap(0x4B, 0)
  remap(0x4D, 1)
  remap(0x4F, 2)
  remap(0x47, 3)
  remap(0x5B, 4)
  remap(0x5C, 5)
  remap(0x5D, 6)
  remap(0x5E, 7)
  remap(0x5F, 8)
  remap(0x58, 9)
  remap(0x59, 10)
  remap(0x61, 11)
  remap(0x8F, 14, 14, 16)
  remap(0x91, 15, 15, 17)
  remap(0xA7, 26, 28, nil, 28, 29)
  remap(0xA9, 27, 29, nil, 30)
  remap(0xA1, 23, 25)
  remap(0xA3, 24, 26)
  remap(0xA5, 25, 27)
  remap(0x5A, 12)
  remap(0x49, 13)
  remap(0x9B, 16, 18)
  remap(0x9D, 17, 19)
  remap(0x9F, 18, 20)
  remap(0x93, 19, 21)
  remap(0x95, 20, 22)
  remap(0x97, 21, 23)
  remap(0x99, 22, 24)
  remap(0xAB, 28, 30, nil, 31)
  remap(0xAD, 29, 31, nil, 32)
end

local function load_larger(size, fonts, characters, x_height)
  local chars, _ = {}
  local mapping_e, mapping_f, mapping_g = mappings_larger[3], mappings_larger[5], mappings_larger[6]
  if not mapping_e then
    mapping_e = {
      [0xB0] = 0x23DE, -- ⏞
      [0x90] = 0x23DF, -- ⏟
    }
    mappings_larger[3] = mapping_e
  end
  _, chars[1] = load_font('mt2exe', 2*size, mapping_e, fonts, characters)
  if not mapping_f then
    mapping_f = {}
    mappings_larger[5] = mapping_f
  end
  _, chars[2] = load_font('mt2exf', 4*size, mapping_f, fonts, characters)
  if not mapping_g then
    mapping_g = {}
    mappings_larger[6] = mapping_g
  end
  _, chars[3] = load_font('mt2exg', 8*size, mapping_g, fonts, characters)

  local mappings = {remap_largesymbols_up, mapping_e, mapping_f, mapping_g}
  local function remap(entry)
    local char, vert_variants
    for i = 1, 4 do
      local mapping = mappings[i]

      local cid = mapping[entry]
      if char then char.next = cid end
      repeat
        local next_char = assert(characters[cid])
        if next_char.vert_variants then
          assert(not vert_variants)
          vert_variants = cid
          break
        end
        char = next_char
        cid = char.next
      until not cid
    end
    char.next = vert_variants
  end

  remap(0x00) -- (
  remap(0x01) -- )
  -- No remap: [ / ]
  remap(0x08) -- { / 0x66
  remap(0x09) -- } / 0x67
  remap(0x0A) -- < / \langle
  remap(0x0B) -- > / \rangle
  remap(0x0E) -- /
  remap(0x0F) -- \
  remap(0x70) -- \sqrt

  remap(0x62) -- \hat
  remap(0x65) -- \tilde
  remap(0x7A) -- \check

  -- The arcs are more annoying because they don't start at consistent points across fonts...
  characters[remap_largesymbols_up[0xC2]].next = mapping_e[0xD0]
  characters[mapping_e[0xD6]].next = mapping_f[0xB1]
  characters[mapping_f[0xB1]].next = mapping_g[0xB1]

  -- \underbrace
  do
    local char
    for i=0x90, 0xA0 do
      local mapped = mapping_e[i]
      if char then char.next = mapped end
      char = assert(characters[mapped])
    end
    for i=0x90, 0x9B do
      local mapped = mapping_f[i]
      char.next = mapped
      char = assert(characters[mapped])
    end
    for i=0x90, 0x95 do
      local mapped = mapping_g[i]
      char.next = mapped
      char = assert(characters[mapped])
    end
  end

  -- \overbrace
  do
    local char
    local shift = {'down', -x_height}
    for i=0xB0, 0xC0 do
      local mapped = mapping_e[i]
      if char then char.next = mapped end
      char = assert(characters[mapped])
      char.height = char.height + x_height
      table.insert(char.commands, 1, shift)
    end
    for i=0xA0, 0xAB do
      local mapped = mapping_f[i]
      char.next = mapped
      char = assert(characters[mapped])
      char.height = char.height + x_height
      table.insert(char.commands, 1, shift)
    end
    for i=0xA0, 0xA5 do
      local mapped = mapping_g[i]
      char.next = mapped
      char = assert(characters[mapped])
      char.height = char.height + x_height
      table.insert(char.commands, 1, shift)
    end
  end
end

local function build_math_constants(mathsy, mathex)
  local math_x_height = mathsy.x_height
  local math_quad = mathsy.quad
  local num1 = mathsy[8]
  local num2 = mathsy[9]
  local num3 = mathsy[10]
  local denom1 = mathsy[11]
  local denom2 = mathsy[12]
  local sup1 = mathsy[13]
  local sup2 = mathsy[14]
  local sup3 = mathsy[15]
  local sub1 = mathsy[16]
  local sub2 = mathsy[17]
  local sup_drop = mathsy[18]
  local sub_drop = mathsy[19]
  local delim1 = mathsy[20]
  local delim2 = mathsy[21]
  local axis_height = mathsy[22]

  local default_rule_thickness = mathex[8]
  local big_op_spacing1 = mathex[9]
  local big_op_spacing2 = mathex[10]
  local big_op_spacing3 = mathex[11]
  local big_op_spacing4 = mathex[12]
  local big_op_spacing5 = mathex[13]

  return {
    -- Not used by the engine
    ScriptPercentScaleDown = 70,
    ScriptScriptPercentScaleDown = 55,
    -- DelimitedSubFormulaMinHeight = unused(),
    -- DisplayOperatorMinHeight = unset(),
    -- MathLeading = unused(),
    AxisHeight = axis_height,
    AccentBaseHeight = math_x_height,
    -- FlattenedAccentBaseHeight = unused(),
    SubscriptShiftDown = sub1,
    SubscriptTopMax = abs(math_x_height * 4) / 5,
    SubscriptBaselineDropMin = sub_drop,
    SuperscriptShiftUp = sup1,
    SuperscriptShiftUpCramped = sup3,
    SuperscriptBottomMin = abs(math_x_height / 4),
    SuperscriptBaselineDropMax = sup_drop,
    SubSuperscriptGapMin = 4 * default_rule_thickness,
    SuperscriptBottomMaxWithSubscript = abs(math_x_height * 4) / 5,
    SpaceAfterScript = script_space,
    UpperLimitGapMin = big_op_spacing1,
    UpperLimitBaselineRiseMin = big_op_spacing3,
    LowerLimitGapMin = big_op_spacing2,
    LowerLimitBaselineDropMin = big_op_spacing4,
    StackTopShiftUp = num3,
    StackTopDisplayStyleShiftUp = num1,
    StackBottomShiftDown = denom2,
    StackBottomDisplayStyleShiftDown = denom1,
    StackGapMin = 3 * default_rule_thickness,
    StackDisplayStyleGapMin = 7 * default_rule_thickness,
    StretchStackTopShiftUp = big_op_spacing3,
    StretchStackBottomShiftDown = big_op_spacing4,
    StretchStackGapAboveMin = big_op_spacing2,
    StretchStackGapBelowMin = big_op_spacing1,
    FractionNumeratorShiftUp = num2,
    FractionNumeratorDisplayStyleShiftUp = num1,
    FractionDenominatorShiftDown = denom2,
    FractionDenominatorDisplayStyleShiftDown = denom1,
    FractionNumeratorGapMin = default_rule_thickness,
    FractionNumeratorDisplayStyleGapMin = 3 * default_rule_thickness,
    FractionRuleThickness = default_rule_thickness,
    FractionDenominatorGapMin = default_rule_thickness,
    FractionDenominatorDisplayStyleGapMin = 3 * default_rule_thickness,
    SkewedFractionHorizontalGap = math_quad / 2,
    SkewedFractionVerticalGap = math_x_height,
    OverbarVerticalGap = 3 * default_rule_thickness,
    OverbarRuleThickness = default_rule_thickness,
    OverbarExtraAscender = default_rule_thickness,
    UnderbarVerticalGap = 3 * default_rule_thickness,
    UnderbarRuleThickness = default_rule_thickness,
    UnderbarExtraDescender = default_rule_thickness,
    RadicalVerticalGap = default_rule_thickness + abs(default_rule_thickness) / 4,
    RadicalDisplayStyleVerticalGap = default_rule_thickness + abs(math_x_height) / 4,
    -- RadicalRuleThickness = unset(),
    RadicalExtraAscender = default_rule_thickness,
    -- RadicalKernBeforeDegree = unset(),
    -- RadicalKernAfterDegree = unset(),
    -- RadicalDegreeBottomRaisePercent = unset(),
    MinConnectorOverlap = 0,
    -- SubscriptShiftDownWithSuperscript = none(),
    FractionDelimiterSize = delim2,
    FractionDelimiterDisplayStyleSize = delim1,
    -- NoLimitSubFactor = none(),
    -- NoLimitSupFactor = none(),
  }
end

return function(request)
  -- print(require'inspect'(request))
  local features = request.features.normal
  local ssty = features.ssty

  local factor = request.size / designsize

  local fonts, characters = {}, {}

  load_serif(request.size, fonts, characters)
  load_sans(request.size, fonts, characters)
  load_cal(features.cal or 'cm', request.size, fonts, characters, ssty)
  load_frak('euler', request.size, fonts, characters, ssty)
  load_bb(request.size, fonts, characters, ssty)
  local param_letters = load_letters(request.size, fonts, characters, ssty)
  load_bold(request.size, fonts, characters, ssty)
  local param_symbols = load_symbols(request.size, fonts, characters, ssty)
  local param_large = load_largesymbols(request.size, fonts, characters, ssty)

  local constants = build_math_constants(param_symbols, param_large)
  load_xl(request.size, fonts, characters)
  load_larger(request.size, fonts, characters, param_symbols.x_height)

  cross_family_extensions(characters)

  return {
    name = request.name,
    characters = characters,
    designsize = designsize,
    size = request.size,
    parameters = get_parameters(features.mathfontdimen or 'xetex', constants, param_letter, param_symbols, param_large),
    type = 'virtual',
    oldmath = true, -- For now
    fonts = fonts,
    resources = { -- These don't do anything, but they are needed to satisfy unicode-math check that we are a math font
      features = {
        gsub = {
          ssty = {
            math = {
              dflt = {},
            },
          },
        },
      },
    },
    MathConstants = constants,
    mathparameters = constants,
  }
end
