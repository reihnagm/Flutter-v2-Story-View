import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:story_view_app/providers/auth/auth.dart';

import 'package:story_view_app/utils/box_shadow.dart';
import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

import 'package:story_view_app/views/basewidgets/button/custom.dart';
import 'package:story_view_app/views/basewidgets/snackbar/snackbar.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({ Key? key }) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();

  late AuthProvider authProvider;

  late TextEditingController fullnameC;
  late TextEditingController phoneNumberC;
  late TextEditingController passwordC;
  late TextEditingController passwordConfirmC;

  File? file;
  PlatformFile? image;

  bool passwordObscure = true;
  bool passwordConfirmObscure = true;

  @override 
  void initState() {
    super.initState();
    fullnameC = TextEditingController();
    phoneNumberC = TextEditingController();
    passwordC = TextEditingController();
    passwordConfirmC = TextEditingController(); 
  }

  @override 
  void dispose() {
    fullnameC.dispose();
    phoneNumberC.dispose();
    passwordC.dispose();
    passwordConfirmC.dispose();
    super.dispose();
  }

  Future<void> chooseAva() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    PlatformFile? f = result!.files[0];
    image = f;
    File? cropped = await ImageCropper().cropImage(
      sourcePath: f.path!,
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: "Potong"
        toolbarColor: Colors.blueGrey[900],
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false
      ),
      iosUiSettings: const IOSUiSettings(
        minimumAspectRatio: 1.0,
      )
    );  
    if(cropped != null) {
      setState(() => file = cropped);
    } else {
      setState(() => file = null);
    }
  }

  Future<void> register() async {
    String fullname = fullnameC.text;
    String phone = phoneNumberC.text;
    String pass = passwordC.text;
    String passConfirm = passwordConfirmC.text;
  
    if(fullname.trim().isEmpty) {
      ShowSnackbar.snackbar(context, "Nama Lengkap wajib diisi", "", ColorResources.error);
      return;
    }

    if(phone.trim().isEmpty) {
      ShowSnackbar.snackbar(context, "Nomor Ponsel wajib diisi", "", ColorResources.error);
      return;
    }

    if(phone.trim().length < 6) {
      ShowSnackbar.snackbar(context, "Nomor Ponsel Minimal 6 Karakter", "", ColorResources.error);
      return;
    }

    if(pass.trim().isEmpty) {
      ShowSnackbar.snackbar(context, "Kata Sandi wajib diisi", "", ColorResources.error);
      return;
    }

    if(pass.trim().length < 8) {
      ShowSnackbar.snackbar(context, "Kata Sandi Maksimal 8 Karakter", "", ColorResources.error);
      return;
    }

    if(passConfirm.trim().length < 8) {
      ShowSnackbar.snackbar(context, "Konfirmasi Kata Sandi Maksimal 8 Karakter", "", ColorResources.error);
      return;
    }

    if(pass != passConfirm) {
      ShowSnackbar.snackbar(context, "Konfirmasi Kata Sandi tidak sama", "", ColorResources.error);
      return;
    }

    await authProvider.signUp(context, 
      fullname: fullname,
      phone: phone,
      pass: pass,
      pic: file!
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildUI();
  }

  Widget buildUI() {
    return Builder(
      builder: (BuildContext context) {
        authProvider = context.read<AuthProvider>();
        return Scaffold(
          backgroundColor: ColorResources.backgroundColor,
          key: globalKey,
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: [

                  CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [

                      SliverAppBar(
                        backgroundColor: ColorResources.transparent,
                        leading: CupertinoNavigationBarBackButton(
                          color: ColorResources.black,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 80.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            
                            Container(
                              margin: EdgeInsets.only(
                                top: Dimensions.marginSizeDefault,
                                left: Dimensions.marginSizeDefault, 
                                right: Dimensions.marginSizeDefault,
                                bottom: Dimensions.marginSizeLarge
                              ),       
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Daftar",
                                    style: TextStyle(
                                      fontSize: Dimensions.fontSizeLarge,
                                      fontWeight: FontWeight.bold,
                                      color: ColorResources.black,
                                    ),
                                  )
                                ],
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(
                                top: Dimensions.marginSizeExtraSmall,
                                left: Dimensions.marginSizeDefault,
                                right: Dimensions.marginSizeDefault,
                                bottom: Dimensions.marginSizeDefault
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  file != null 
                                  ? SizedBox(
                                      height: 70.0,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          CircleAvatar(
                                            maxRadius: 30.0,
                                            backgroundColor: ColorResources.loaderBluePrimary,
                                            child: Image.file(
                                              file!,
                                              width: 100.0,
                                              height: 100.0,
                                            )
                                          ),
                                          Positioned(
                                            bottom: 0.0,
                                            left: 0.0,
                                            right: 0.0,
                                            child: InkWell(
                                              onTap: () => chooseAva(),
                                              child: const Icon(
                                                Icons.edit,
                                                size: 20.0,
                                                color: ColorResources.black,
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                  )
                                  : SizedBox(
                                      height: 70.0,
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          const CircleAvatar(
                                            maxRadius: 30.0,
                                            backgroundColor: ColorResources.loaderBluePrimary,
                                            child: Icon(
                                              Icons.person,
                                              size: 20.0,
                                              color: ColorResources.white,
                                            )
                                          ),
                                          Positioned(
                                            bottom: 0.0,
                                            left: 0.0,
                                            right: 0.0,
                                            child: InkWell(
                                              onTap: () => chooseAva(),
                                              child: const Icon(
                                                Icons.edit,
                                                size: 20.0,
                                                color: ColorResources.black,
                                              ),
                                            )
                                          ),
                                        ],
                                      ),
                                  )
                                ],
                              )
                            ),

                            Container(
                              margin: EdgeInsets.only(
                                top: Dimensions.marginSizeExtraSmall,
                                left: Dimensions.marginSizeDefault, 
                                right: Dimensions.marginSizeDefault,
                                bottom: Dimensions.marginSizeDefault
                              ),
                              child: TextField(
                                controller: fullnameC,
                                style: openSans.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall
                                ),
                                cursorColor: ColorResources.black,
                                decoration: InputDecoration(
                                  hintText: "",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: "Nama Lengkap", 
                                  labelStyle: openSans.copyWith(
                                    color: ColorResources.black,
                                    fontSize: Dimensions.fontSizeExtraSmall
                                  ),
                                  border: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorResources.black
                                    )
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorResources.black
                                    )
                                  )
                                )
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(
                                top: Dimensions.marginSizeExtraSmall, 
                                left: Dimensions.marginSizeDefault, 
                                right: Dimensions.marginSizeDefault,
                                bottom: Dimensions.marginSizeDefault
                              ),
                              child: TextField(
                                controller: phoneNumberC,
                                style: openSans.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall
                                ),
                                cursorColor: ColorResources.black,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: "",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: "Nomor Ponsel", 
                                  labelStyle: openSans.copyWith(
                                    color: ColorResources.black,
                                    fontSize: Dimensions.fontSizeExtraSmall
                                  ),
                                  border: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorResources.black
                                    )
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorResources.black
                                    )
                                  )
                                )
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(
                                top: Dimensions.marginSizeExtraSmall, 
                                left: Dimensions.marginSizeDefault, 
                                right: Dimensions.marginSizeDefault,
                                bottom: Dimensions.marginSizeDefault
                              ),
                              child: TextField(
                                controller: passwordC,
                                style: openSans.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall
                                ),
                                cursorColor: ColorResources.black,
                                maxLength: 8,
                                obscureText: passwordObscure,
                                decoration: InputDecoration(
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() => passwordObscure = !passwordObscure);
                                    },
                                    child: passwordObscure 
                                    ? const Icon(Icons.visibility_off) 
                                    : const Icon(Icons.visibility),
                                  ),
                                  hintText: "",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: "Kata Sandi", 
                                  labelStyle: openSans.copyWith(
                                    color: ColorResources.black,
                                    fontSize: Dimensions.fontSizeExtraSmall
                                  ),
                                  border: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorResources.black
                                    )
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorResources.black
                                    )
                                  )
                                )
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(
                                left: Dimensions.marginSizeDefault, 
                                right: Dimensions.marginSizeDefault,
                                bottom: Dimensions.marginSizeDefault
                              ),
                              child: TextField(
                                controller: passwordConfirmC,
                                style: openSans.copyWith(
                                  fontSize:  Dimensions.fontSizeExtraSmall
                                ),
                                cursorColor: ColorResources.black,
                                maxLength: 8,
                                obscureText: passwordConfirmObscure,
                                decoration: InputDecoration(
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() => passwordConfirmObscure = !passwordConfirmObscure);
                                    },
                                    child: Icon(
                                      passwordConfirmObscure 
                                      ? Icons.visibility_off
                                      : Icons.visibility 
                                    ),
                                  ),
                                  hintText: "",
                                  floatingLabelBehavior: FloatingLabelBehavior.always,
                                  labelText: "Konfirmasi Kata Sandi", 
                                  labelStyle: openSans.copyWith(
                                    color: ColorResources.black,
                                    fontSize: Dimensions.fontSizeExtraSmall
                                  ),
                                  border: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorResources.black
                                    )
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: ColorResources.black
                                    )
                                  )
                                )
                              ),
                            ),

                          ])
                        )
                      )

                    ],
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CustomButton(
                      onTap: register,
                      height: 56.0, 
                      btnTxt: "Selanjutnya",
                      btnColor: ColorResources.loaderBluePrimary,
                      btnTextColor: ColorResources.white,
                      isLoading: context.watch<AuthProvider>().registerStatus == RegisterStatus.loading 
                      ? true  
                      : false,
                      isBorder: false,
                      isBorderRadius: false,
                      isBoxShadow: true,
                    ),
                  ),

                ],
              );
            },
          )
        );
      }, 
    );
  }
}