import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:story_view_app/providers/auth/auth.dart';

import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

import 'package:story_view_app/views/screens/auth/sign_in.dart';

class SignOutConfirmationDialog extends StatelessWidget {
  const SignOutConfirmationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: 50),
            child: Text("Apakah kamu yakin ingin keluar?", 
              style: openSans.copyWith(
                fontSize: Dimensions.fontSizeExtraSmall
              ), 
              textAlign: TextAlign.center
            ),
          ),
          const Divider(
            height: 0.0, 
            color: ColorResources.hintColor
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [

              Expanded(
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: ColorResources.white, 
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10.0)
                      )
                    ),
                    child: Text("Tidak", 
                      style: openSans.copyWith(
                        color: ColorResources.black,
                        fontSize: Dimensions.fontSizeExtraSmall,
                      )
                    ),
                  ),
                )
              ),

              Expanded(
                child: InkWell(
                onTap: () {
                  context.read<AuthProvider>().logout();
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SignInScreen()), (route) => false);
                },
                child: Container(
                  padding: EdgeInsets.all(Dimensions.paddingSizeSmall),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: ColorResources.error,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0)
                    )
                  ),
                  child: Text("Ya", 
                    style: openSans.copyWith(
                      color: ColorResources.white,
                      fontSize: Dimensions.fontSizeExtraSmall
                    )
                  ),
                ),
              )
            ),
        
          ]),
        ]
      ),
    );
  }
}
