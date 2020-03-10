% Step 0: Get file
[s10, fs10] = getFile(10);
[s2, fs2] = getFile(2);
[s7, fs7] = getFile(7);
[s6, fs6] = getFile(6);
[s5, fs5] = getFile(5);
[s4, fs4] = getFile(4);

inputDic = train42(s2, fs2, "s2");
inputDic = train42(s4, fs4, "s4", inputDic);
inputDic = train42(s5, fs5, "s5", inputDic);
inputDic = train42(s6, fs6, "s6", inputDic);
inputDic = train42(s7, fs7, "s7", inputDic);
inputDic = train42(s10, fs10, "s10", inputDic);