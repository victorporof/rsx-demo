/*
Copyright 2016 Mozilla
Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
*/

#![feature(box_syntax)]
#![feature(proc_macro)]
#![feature(link_args)]

extern crate rsx;
#[macro_use]
extern crate rsx_embedding;

use rsx::{css, load_font, load_image, rsx};
use rsx_embedding::rsx_dom::types::*;
use rsx_embedding::rsx_primitives::prelude::{DOMTree, ResourceGroup};
use rsx_embedding::rsx_resources::fonts::types::EncodedFont;
use rsx_embedding::rsx_resources::images::types::{EncodedImage, ImageEncodingFormat};
use rsx_embedding::rsx_shared::traits::{TDOMNode, TFontCache, TImageCache, TResourceGroup};
use rsx_embedding::rsx_stylesheet::types::*;

link! {
    setup,
    render
}

fn setup(resources: &mut ResourceGroup) {
    let logo = load_image!("fixtures/images/Quantum.png");
    resources.images().add_image("app://logo.png", &logo);

    let font = load_font!("fixtures/fonts/FreeSans.ttf");
    resources.fonts().add_font("FreeSans", &font, 0);
}

fn render() -> DOMTree {
    let mut stylesheet = css!("src/example.css");

    rsx! {
        <view style={stylesheet.take(".center")}>
            <view style={stylesheet.take(".root")}>
                <image style={stylesheet.take(".image")} src="app://logo.png" />
                <text style={stylesheet.take(".text")}>
                    { "Hello World!" }
                </text>
            </view>
        </view>
    }
}
