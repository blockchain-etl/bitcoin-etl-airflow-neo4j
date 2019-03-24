#!/usr/bin/env python3

import jinja2
import argparse


def parse_pair(pair):
    key, value = pair.split('=')

    nested_fields = key.split('.')[::-1]
    result = {nested_fields[0]: value}
    for field in nested_fields[1:]:
        result = {field: result}

    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--template', help="Path of the template file", required=True)
    parser.add_argument("--set",
                        metavar="KEY=VALUE",
                        nargs='+',
                        help="Set a number of key-value pairs "
                             "(do not put spaces before or after the = sign). "
                             "If a value contains spaces, you should define "
                             "it with double quotes: "
                             'foo="this is a sentence". Note that '
                             "values are always treated as strings.")

    args = parser.parse_args()
    # Workout template parameters
    template_args = {}
    for param in [parse_pair(pair) for pair in args.set]:
        template_args.update(param)

    template_loader = jinja2.FileSystemLoader(searchpath='../dags/')
    template_env = jinja2.Environment(loader=template_loader)
    template = template_env.get_template(args.template)
    print(template.render(**template_args))


if __name__ == '__main__':
    main()
