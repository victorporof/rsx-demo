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

#![feature(proc_macro)]
#![feature(link_args)]

extern crate rsx;
#[macro_use]
extern crate rsx_renderers;

use rsx::{css, rsx};
use rsx_renderers::rsx_dom::types::*;
use rsx_renderers::rsx_stylesheet::types::*;

fn todo_item(done: bool, text_contents: &'static str) -> NodeFragment {
    let mut stylesheet = css!("src/example.css");
    rsx! {
        <view style={stylesheet.get(".list-item")}>
            <text style={stylesheet.get(if done { ".checkbox-checked" } else { ".checkbox-empty" }) }>
            {
                if done { "☑" } else { "☐" }
            }
            </text>
            <text style={stylesheet.get(".text")}>
            {
                text_contents
            }
            </text>
        </view>
    }
}

fn question() -> NodeFragment {
    let mut stylesheet = css!("src/example.css");
    rsx! {
        <text style={stylesheet.get(".list-item")}>
            ???
        </text>
    }
}

fn todo_list() -> NodeFragment {
    let mut stylesheet = css!("src/example.css");
    rsx! {
        <view style={stylesheet.get(".list")}>
            { todo_item(true, "Build proof of concept") }
            { todo_item(false, "Handle user input") }
            { todo_item(false, "Standardize") }
            { question() }
            { todo_item(false, "Profit.") }
        </view>
    }
}

fn root() -> NodeFragment {
    let mut stylesheet = css!("src/example.css");
    rsx! {
        <view style={stylesheet.get(".root")}>
            <image style={stylesheet.get(".image")} src="http://i.imgur.com/7Ih60Gu.png" />
            {
                todo_list()
            }
        </view>
    }
}

link! {
    fn render() -> Node {
        Node::from(root())
    }
}
