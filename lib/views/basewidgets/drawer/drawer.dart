
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:story_view_app/providers/auth/auth.dart';

import 'package:story_view_app/utils/color_resources.dart';
import 'package:story_view_app/utils/constant.dart';
import 'package:story_view_app/utils/custom_themes.dart';
import 'package:story_view_app/utils/dimensions.dart';

import 'package:story_view_app/views/basewidgets/dialog/animated/animated.dart';
import 'package:story_view_app/views/basewidgets/dialog/logout/logout.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({ Key? key }) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: ColorResources.white,
        child: ListView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.zero,
          children: [
    
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(
                color: ColorResources.greyBottomNavbar
              ),
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    CachedNetworkImage(
                      imageUrl: "${AppConstants.baseUrl}/images/${context.read<AuthProvider>().getPic}",
                      imageBuilder: (BuildContext context, ImageProvider imageProvider) {
                        return CircleAvatar(
                          maxRadius: 30.0,
                          backgroundColor: ColorResources.greyBottomNavbar,
                          backgroundImage: imageProvider,
                        );
                      },
                      placeholder: (BuildContext context, String error) {
                        return const CircleAvatar(
                          maxRadius: 30.0,
                          backgroundColor: ColorResources.grey,
                        );
                      },
                      errorWidget: (BuildContext context, String error, dynamic val) {
                        return const CircleAvatar(
                          maxRadius: 30.0,
                          backgroundColor: ColorResources.grey,
                        );
                      },
                    ),

                    const SizedBox(height: 5.0),

                    Text(context.read<AuthProvider>().getFullname,
                      style: openSans.copyWith(
                        fontSize: Dimensions.fontSizeExtraSmall,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              )
            ),

            ListTile(
              dense: true,
              onTap: () {
                showAnimatedDialog(
                  context,
                  const SignOutConfirmationDialog(),
                  isFlip: true
                );
              },
              contentPadding: const EdgeInsets.only(
                top: 8.0,
                bottom: 8.0,
                left: 16.0, 
                right: 16.0,
              ),
              title: Text("Logout",
                style: openSans.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: ColorResources.black
                ),
              ),
              leading: const Icon(
                Icons.exit_to_app,
                color: ColorResources.grey,
              )
            )
            
    
          ],
        ),
      ),
    );
  }
}