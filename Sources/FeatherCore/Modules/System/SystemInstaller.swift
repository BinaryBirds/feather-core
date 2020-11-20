//
//  SystemInstaller.swift
//  Feather
//
//  Created by Tibor Bodecs on 2020. 11. 14..
//

struct SystemInstaller: ViperInstaller {

    func variables() -> [[String: Any]] {
        [
            [
                "key": "site.title",
                "value": "Feather",
                "note": "Title of the website",
                "hidden": true,
            ],
            [
                "key": "site.excerpt",
                "value": "Feather is an open-source CMS written in Swift using Vapor 4.",
                "note": "Description of the website",
                "hidden": true,
            ],
            [
                "key": "site.color.primary",
                "note": "Primary color of the website",
                "hidden": true,
            ],
            [
                "key": "site.color.secondary",
                "note": "Secondary color of the website",
                "hidden": true,
            ],
            [
                "key": "site.font.family",
                "note": "Custom font family for the site",
                "hidden": true,
            ],
            [
                "key": "site.font.size",
                "note": "Custom font size for the site",
                "hidden": true,
            ],
            [
                "key": "site.css",
                "note": "Global CSS injection for the site",
                "hidden": true,
            ],
            [
                "key": "site.js",
                "note": "Global JavaScript injection for the site",
                "hidden": true,
            ],
            [
                "key": "site.footer",
                "value": "<img class=\"w64\" src=\"/images/icons/icon.png\" alt=\"Logo of Feather\" title=\"Feather\">",
                "note": "Custom contents for the footer",
                "hidden": true,
            ],
            [
                "key": "site.copy",
                "value": "This site is powered by <a href=\"https://github.com/binarybirds/feather\" target=\"_blank\">Feather</a>",
                "note": "",
                "hidden": true,
            ],
            [
                "key": "site.copy.start.year",
                "note": "Start year placed before the current one in the copy line",
                "hidden": true,
            ],
            [
                "key": "site.footer.bottom",
                "note": "Bottom footer content placed under the footer menu",
                "hidden": true,
            ],
            [
                "key": "home.page.title",
                "value": "Home page title",
                "note": "Title of the home page",
            ],
            [
                "key": "home.page.description",
                "value": "Home page description",
                "note": "Description of the home page",
            ],
            [
                "key": "page.not.found.icon",
                "value": "🙉",
                "note": "Icon for the not found page",
            ],
            [
                "key": "page.not.found.title",
                "value": "Page not found",
                "note": "Title of the not found page",
            ],
            [
                "key": "page.not.found.description",
                "value": "Unfortunately the requested page is not available.",
                "note": "Description of the not found page",
            ],
            [
                "key": "page.not.found.link",
                "value": "Go to the home page →",
                "note": "Retry link text for the not found page",
            ],
            [
                "key": "empty.list.icon",
                "value": "🔍",
                "note": "Icon for the empty list box",
            ],
            [
                "key": "empty.list.title",
                "value": "Empty list",
                "note": "Title of the empty list box",
            ],
            [
                "key": "empty.list.description",
                "value": "Unfortunately there are no results.",
                "note": "Description of the empty list box",
            ],
            [
                "key": "empty.list.link",
                "value": "Try again from scratch →",
                "note": "Start over link text for the empty list box",
            ],
            [
                "key": "share.isEnabled",
                "value": "true",
                "note": "The share box is only displayed if this variable is true",
            ],
            [
                "key": "share.link.prefix",
                "value": "Thanks for reading, if you liked this article please",
                "note": "Appears before the share link",
            ],
            [
                "key": "share.link",
                "value": "share it on Twitter",
                "note": "Share link title, will be placed after share text",
            ],
            [
                "key": "share.link.suffix",
                "value": ".",
                "note": "Appears after the share link",
            ],
            [
                "key": "share.author",
                "value": "tiborbodecs",
                "note": "Share author",
            ],
            [
                "key": "share.hashtags",
                "value": "SwiftLang",
                "note": "Share hashtasgs",
            ],
            [
                "key": "post.author.isEnabled",
                "value": "true",
                "note": "Display post author box if this variable is true",
            ],
            [
                "key": "post.footer",
                "note": "Display the contents of this value under every post entry",
            ],
        ]
    }
}
